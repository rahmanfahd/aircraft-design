### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 7681f7f4-5830-4860-a67d-c2acd1ed8218
using Plots

# ╔═╡ b79ef21d-e232-4c10-a0ba-6b4c54ad71aa
begin
	using PlutoUI
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));
	alert(text=md"Alert!") = Markdown.MD(Markdown.Admonition("danger", "Alert!", [text]));
	exercise(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("correct", "Exercise", [text]));
	warning(text=md"Warning.") = Markdown.MD(Markdown.Admonition("warning", "Warning!", [text]));
	correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]));
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));
end;

# ╔═╡ 69b42df0-8ae2-11eb-0bba-1983308b31c6
md"""
# Preliminary Weight, CG and Static Margin Estimation

"""

# ╔═╡ e76379e2-4d75-4b74-800d-8672941dc9a5
plotlyjs()

# ╔═╡ 8da00018-3cac-40d0-8d49-14a147467387
begin
	S_W=27#wing reference area
	
	#canard
	AR_H=0.9*4.5
	lambda_H=0#LE sweep
	S_H=8.26#reference area
	#l_H=5.265967537251188 #cg to local  cg
	
	#vertical stabilizer_wingtip
	#AR_V1=1.38
	#lambda_V1=36
	#S_V1=1.38
	#l_V1=7.755
	
	#Vertical stabilizer_fin
	#AR_V2=0.58
	#lambda_V2=45
	#S_V2=0.58
	#l_V2=7.2
	
	#other
	Mach=0.235
	Eta=0.97
	Eta_H=0.9
	
	#Fuselage
	L_F=9
	w_F=1.8
	S_F=33.9
end;

# ╔═╡ 0b5a24d0-8b00-11eb-224a-8b6fb1aff81a
md""" 
## Estimating Mean Aerodynamic Chord Location
![](https://godot-bloggy.xyz/post/diagrams/WingParams.svg)

From the trapezoidal geometry:
```math
x_{40\%~\text{MAC}} = x_{\text{LE},\ \text{MAC}} + 0.4\bar{c}, \quad \text{where} \quad x_{\text{LE},\ \text{MAC}} = x_{\text{LE},\ \text{root}} + \bar Y\tan\Lambda_{\text{LE}}
```

"""

# ╔═╡ e8dad1e6-7477-42cc-b8e3-c518af7d9b52
begin
	# Vertical stabilizer
	S_v = 604
	lambda_v = deg2rad(44.4)
end;

# ╔═╡ a3b5d8b0-89e2-11eb-1040-031e0142ca7c
struct LiftingSurface
	c_root 		:: Float64
	c_tip 		:: Float64
    x_RLE 		:: Float64
    b 			:: Float64
    sweep_LE 	:: Float64
    taper 		:: Float64
end

# ╔═╡ 780dc91e-e6cf-4013-a04a-b35fa0fa9755
struct VaryingTaperLiftingSurface
	yB:: Float64
	x_rootLE :: Float64
	c_root:: Float64
	c_B :: Float64
	b :: Float64
	c_tip :: Float64
	taper_inner :: Float64
	taper :: Float64
	sweep_LEinner :: Float64
	sweep_LEouter :: Float64
	sweep_TE :: Float64
end

# ╔═╡ c82ef9d0-89e5-11eb-02d1-db611f26e0b6
md"""
Define a function for MAC with linear taper
```math
\bar{c}=\frac{2}{3}\left(\frac{1+\lambda+\lambda^2}{1+\lambda}\right)c_\text{root},~ \bar{Y}=\frac{b}{6}\left(\frac{1+2\lambda}{1+\lambda}\right)
```
"""

# ╔═╡ 3d325ff0-2a5e-4267-86f1-41c2cc25d7b1
md"""
Defined function for MAC for wings with cranked leading and trailing edges
```math
c_{\text{MAC}}=\frac{2}{3} c_{r} \frac{(\lambda_{i}^2 + \lambda_{i}\lambda+\lambda^2) + \left [ \frac{y_{B}}{(b/2 - y_{B})} \right ] (1+\lambda_{i}+\lambda_{i}^2) }{(\lambda_{i}^2+\lambda) + \left [ \frac{y_{B}}{(b/2 - y_{B})} \right ](1+\lambda_{i}^2)}
```
```math
y_{\text{MAC}}=\frac{1}{3} \left ( \frac{b}{2} -y_{B}\right ) \frac{\lambda_{i} \left (1 + 2 \lambda_{i} \lambda \right) + \left [ \frac{y_{B}}{(b/2) -y_{B}} \right ] (2+\lambda_{i}\lambda ) + \left [ \frac{y_{B}}{(b/2) -y_{B}} \right ]^2 (1+2\lambda_{i})}{(\lambda_{i}+\lambda)+\left [ \frac{y_{B}}{(b/2) -y_{B}} \right ](1+\lambda_{i})}
```
The above equation is taken from https://www.sciencedirect.com/topics/engineering/mean-aerodynamic-chord

"""

# ╔═╡ 137918a0-8b06-11eb-0f23-2fd22e086911
md"The function defined for MAC along the chord for linear tapered wing"

# ╔═╡ 3053c570-89e3-11eb-1f51-8fb42324f651
mean_aerodynamic_chord(surf :: LiftingSurface) = 2/3 * (1 + surf.taper + surf.taper^2)/(1 + surf.taper) * surf.c_root

# ╔═╡ 11ddb3ae-db3a-41b0-a77d-387f99b0e9a0
md"The function defined for MAC along the chord for cranked LE & TE wing"

# ╔═╡ 09f81461-7713-41fc-a3b9-cc106018ccf5
c_MAC(surf :: VaryingTaperLiftingSurface)=(2/3)*surf.c_root*(((surf.taper_inner^2)+(surf.taper_inner*surf.taper)+(surf.taper^2)+((surf.yB/((surf.b/2)-surf.yB))*(1+surf.taper_inner+(surf.taper_inner^2))))/(surf.taper+(surf.taper_inner^2)+((surf.yB/((surf.b/2)-surf.yB))*(1+surf.taper_inner^2))))

# ╔═╡ 3a8b8e80-89e6-11eb-255d-df692399569f
md"Define a function for MAC for linear-tapered wing along the span-wise direction"

# ╔═╡ 68795e80-89e6-11eb-04da-c9e66888d483
Y_mac(surf :: LiftingSurface) = surf.b * 1/6 * (1 + 2 * surf.taper) / (1 + surf.taper)

# ╔═╡ 3a4723e4-ec74-4d59-b1cd-4d1e99f2434e
md"Define a function for MAC for cranked LE & TE wing along the span-wise direction"

# ╔═╡ 28ad10c1-678a-45e5-85b7-772a99108f0c
yMAC(surf :: VaryingTaperLiftingSurface)=(1/3)*((surf.b/2)-surf.yB)*(((surf.taper_inner*(1+(2*surf.taper_inner*surf.taper)))+((surf.yB/((surf.b/2)-surf.yB))*(2+(surf.taper_inner*surf.taper)))+((surf.yB/((surf.b/2)-surf.yB))^2)*(1+(2*surf.taper_inner)))/(surf.taper_inner+surf.taper+((surf.yB/((surf.b/2)-surf.yB))*(1+surf.taper_inner))))

# ╔═╡ 11a520d0-89e6-11eb-2337-a5c4040b8013
md"Define the values of the wing for its struct."

# ╔═╡ be1b261a-be10-4c60-adad-36614e7b5827
begin 
	#Main wing with LERX
	yB = 2.24#y loc at where it changes sweep
	x_rootLE= 4.252#distance of wing to nose at root
	c_root = 4#root chord
	c_B = 2.1#chord at where it changes sweep
	b_W = 12.6#span of wing
	c_tip = 0.96#chord at tip
	taper_inner = 0.525
	taper_W = 0.24#overall taper
	sweep_LEinner = 56
	sweep_LEouter = 26
	sweep_TE = 12
end;

# ╔═╡ c3824140-28d3-4f0d-8d56-3dbf42dca2cf
function getTaperSweepofMAC(ymac)
	if ymac<yB
		relSweep=sweep_LEinner
	elseif ymac>yB
		relSweep=sweep_LEouter
	elseif ymac>b_W
		relSweep=0
	end
	relSweep
end

# ╔═╡ 12d99410-89e4-11eb-1bbb-6b20dcf1678a
begin
	
	#canards
	croot_h = 0.9
	ctip_h = 0.9
	xRLE_h = 0.675#root LE longitudinal distance from nose
	b_h = 5
	sweepLE_h = 0
	taper_h = ctip_h/croot_h
	S_c=croot_h*b_h
	
	
	#vertical stabilizer at wingtip #concerning wingtip and span
	croot_V1 = 1.65
	ctip_V1 = 0.45
	xRLE_V1 = x_rootLE+(yB*tan(sweep_LEinner))+((b_W-yB)*tan(sweep_LEouter))
	b_V1 = 2
	sweepLE_V1 = 36
	taper_V1 = ctip_V1/croot_V1
	S_wingtip=(((croot_V1+ctip_V1)*b_V1)/2)*2
	
	#vertical stabilizer at fin
	croot_V2=0.58
	ctip_V2=0.45
	xRLE_V2=7.2
	b_V2=0.42
	sweepLE_V2=45
	taper_V2=ctip_V2/croot_V2
	S_aftFin=((croot_V2+ctip_V2)*b_V2)/2
end;

# ╔═╡ 608bc750-8b06-11eb-2123-fb1b2a57a252
md"Structs of type ```LiftingSurface``` are created by applying the ```LiftingSurface``` type as a **function** with inputs for its fields:"

# ╔═╡ 30fe0cc4-7e57-49bc-89b2-ce3b00cc2a65
canard=LiftingSurface(croot_h,ctip_h,xRLE_h,b_h,sweepLE_h,taper_h);

# ╔═╡ 9e1c4b9c-4352-47e0-be98-65cc599474ac
vStab=LiftingSurface(croot_V1,ctip_V1,xRLE_V1,b_V1,sweepLE_V1,taper_V1);

# ╔═╡ cb11e4d7-233f-4779-b9ad-7059bff013c9
finStab=LiftingSurface(croot_V2,ctip_V2,xRLE_V2,b_V2,sweepLE_V2,taper_V2);

# ╔═╡ b356c994-2314-491d-a93d-b5625be04036
Mainwing = VaryingTaperLiftingSurface(yB, x_rootLE, c_root,c_B,b_W,c_tip,taper_inner,taper_W,sweep_LEinner,sweep_LEouter,sweep_TE);

# ╔═╡ 2a7232ae-70a5-4bee-9b63-6d9903701a40
mainWingMAC_c = c_MAC(Mainwing) #Main wing chord MAC

# ╔═╡ f90ac96f-200c-4c00-bb15-f24074865da4
canardMAC_c=mean_aerodynamic_chord(canard)#canard MAC

# ╔═╡ 463f1e3b-365a-4311-a4db-bdbefa66564d
vStabMAC_c=mean_aerodynamic_chord(vStab)#wingtip v. stabilizer MAC

# ╔═╡ 5072dbe8-a88e-4891-8cb6-6a765d055dae
finStabMAC_c=mean_aerodynamic_chord(finStab)#aft fin MAC

# ╔═╡ d76e65a8-9e8f-4665-8fa8-52382d8dfbb2
mainWingMAC_Y=yMAC(Mainwing) #Main wing MAC y.loc, within inboard wing

# ╔═╡ 45d4c80a-5798-4451-a591-c1811ba15fed
canardMAC_Y=Y_mac(canard)#canard MAC y.loc

# ╔═╡ fc3217ef-7fc1-433a-a9b2-84cfda8f04d8
vStabMAC_Y=Y_mac(vStab)+(b_W/2)#vertical stabilizer MAC y.loc

# ╔═╡ 2d4a5450-8b07-11eb-3b69-3dc27e505c50
md"Now you can obtain the CG location of the wing with respect to the reference mean aerodynamic chord location."

# ╔═╡ afaaa1f0-8a0f-11eb-00dc-47d7ecc444a7
wing_mac_origin(surf :: LiftingSurface, percent) = surf.x_RLE + Y_mac(surf) * tan(surf.sweep_LE) + percent / 100 * mean_aerodynamic_chord(surf)

# ╔═╡ 142c524a-3917-430d-aab8-1469dc8effa8
wingMAC_loc_origin(wing :: VaryingTaperLiftingSurface, perc) = wing.x_rootLE + yMAC(wing)*tand(wing.sweep_LEinner) + perc/100*c_MAC(wing)

# ╔═╡ aee47142-8ce8-4189-9bfd-3ee51fbb4cb1
Mainwing_cg40 = wingMAC_loc_origin(Mainwing,40)

# ╔═╡ 197916ee-fe63-4df2-869b-81c440d5ff84
Mainwing_cg25 = wingMAC_loc_origin(Mainwing,25)

# ╔═╡ 3e05470c-1161-4adc-9607-3638368a14d6
Canard_cg40=wing_mac_origin(canard,40)

# ╔═╡ 10ca0d20-b99e-4b6e-a6b3-ecb95d1bf1b0
Canard_cg25=wing_mac_origin(canard,25)

# ╔═╡ 2c683bb7-83d6-409d-850b-9f622cfeefe9
vStab_cg40=wing_mac_origin(vStab,40)

# ╔═╡ f1ab1278-4ab5-423c-a773-5d2e874d06f7
vStab_cg25=wing_mac_origin(vStab,25)

# ╔═╡ b9c58e91-11e8-47db-a331-14691993f212
finStab_cg40=wing_mac_origin(finStab,40)

# ╔═╡ 7a95efd5-9794-43cb-b6cc-970c0899f746
finStab_cg25=wing_mac_origin(finStab,25)

# ╔═╡ 9c13d810-8a13-11eb-07a5-3bcedbd77eac
md"""
## Center of Gravity Estimation

The position of the aircraft’s center of gravity (CG) is given by:
```math
\mathbf{x}_\text{cg} = \frac{\sum_i W_i \ (\mathbf{x}_{\text{cg}})_i}{\sum_i W_i}, \quad \mathbf{x} = \begin{bmatrix}
  x \\ y \\ z
\end{bmatrix}
```

where $W_i$ represents the weight for each component and $\mathbf x_{\text{cg}_i}$ is the longitudinal distance between the origin and the CG of the $i$th component. The product in the form of $W_i \mathbf x_{\text{cg}_i}$ is also referred to as the moment of the $i$th component.


Considering a takeoff gross weight of 2655 kg and using Raymer's reference data, the specific weight and position parameters of the structural components are shown in the following table:

Components | Weight Ratio | Reference Weight (kg) | Approximate Location
:-------- | :-----: | :----------:|----------:
Nose landing gear | 0.057 * 15% - W * 0.014 | 2655 | Centroid
Main landing gear | 0.057 * 85% - W * 0.014 | 2655 | Centroid
Installed engine     | 1.4 | 208.7     | Centroid
“All-else empty”    | 0.1  | 2655     | 40-50% Length

Note: We consider the **nose** as the reference point and **clockwise moments** as positive!
"""

# ╔═╡ 9b2da92a-d97c-485b-ab36-bc775a65a159
begin
	# Filled in quantities
	TOGW = 2858 	 # kg
	w_engine = 363*1.4 # kg
	reserveFuel=0.06
	FuelWF=0.31135388287326593
	TrappedFuel=TOGW*FuelWF*reserveFuel#kg 
	UsableFuel=TOGW*FuelWF/(reserveFuel+1)#kg
	
	
	#weight of Components
	w_MainWing=278.55
	w_fuselage=275.8
	w_canard=82.7475#67.0255
	w_VtailTip=43.99
	w_VtailFin=13.529
	w_MainLG=(0.057*TOGW-(TOGW*0.014))*0.85
	w_NoseLG=(0.057*TOGW-(TOGW*0.014))*0.15
	w_SeatRow1=30*2
	w_SeatRow2=30*3
	w_Crew=90
	w_passenger1=90*1
	w_passenger2=90*3
	w_BRS=40
	
	#cg length
	cg_fuselage=4.05
	cg_MainLG=5.625
	cg_NoseLG=0.825
	cg_SeatRow1=3.825
	cg_SeatRow2=5.325
	cg_engine=8.040
	cg_fuel=5.79
	cg_BRS=6
	
end;

# ╔═╡ 7a540330-8a13-11eb-3e55-c15452e5004c
md"It's convenient to use a function for the moment calculations."

# ╔═╡ ea34f410-8a14-11eb-1556-3b8c3ea0307d
moment(dist, weight) = dist * weight

# ╔═╡ 00d09cb2-8a15-11eb-0638-dffe4c995856
md"For the previously generated wing, the total moment is:"

# ╔═╡ a9ab5c00-8a18-11eb-1992-93bb7c57c029
md"The weight and CG position of each component can hence be computed and included in a dictionary for convenience in calculations."

# ╔═╡ 89bf9247-00c9-4b30-b328-6b1777d474a7
weight_pos = Dict(	"MainWing"   => (w_MainWing,Mainwing_cg40),
						"fuselage"  => (w_fuselage,cg_fuselage),
        				"canard"  => (w_canard,Canard_cg40),
        				"vTailTip"   => (w_VtailTip,vStab_cg40),
        				"vTailFin" => (w_VtailFin,finStab_cg40),
        				"mainLG" => (w_MainLG,cg_MainLG),
        				"noseLG" => (w_NoseLG,cg_NoseLG),
						"SeatRow_1" =>(w_SeatRow1,cg_SeatRow1),
						"SeatRow_2" => (w_SeatRow2,cg_SeatRow2),
						"engine"=> (w_engine,cg_engine),
						"trappedFuel" =>(TrappedFuel,cg_fuel),
						"Crew" => (w_Crew,cg_SeatRow1),
						"usableFuel"=> (UsableFuel,cg_fuel),
						"Passenger1" => (w_passenger1,cg_SeatRow1),
						"Passenger2" => (w_passenger2,cg_SeatRow2),
						"BRS" => (w_BRS,cg_BRS),
						);

# ╔═╡ 4175e400-8a1a-11eb-305d-bf6a7ad893ed
md"Now we can calculate the total moments generated from all the component, i.e., $\sum_i W_i \mathbf x_{\text{cg}_i}$"

# ╔═╡ 5b9711fa-4950-4512-9bec-14d08f594324
moment_list = [ moment(weight, pos_x) for (weight, pos_x) in values(weight_pos) ];

# ╔═╡ b63575a7-d350-496e-a0a7-9653413bfb62
momentSum = sum(moment_list)

# ╔═╡ 84906350-8a1a-11eb-26b6-2324a98f390b
md"The same logic also applies to the total weight, i.e., $\sum_i W_i$"

# ╔═╡ 934c246e-b0b7-4421-8545-a9e7b3d16bd3
tot_weight = sum(weight for (weight, pos_x) in values(weight_pos))

# ╔═╡ a8e2beb4-817f-4de7-a883-f6777c2ab73c
xCG = momentSum/tot_weight

# ╔═╡ 3a64faf2-56cd-438a-a187-a213bcdfcd14
md"""## CG excursion calculation"""

# ╔═╡ edf063b2-54ea-46f5-9d13-854e5014657d
weight_Empty = Dict(	"MainWing"   => (w_MainWing,Mainwing_cg40),
						"fuselage"  => (w_fuselage,cg_fuselage),
        				"canard"  => (w_canard,Canard_cg40),
        				"vTailTip"   => (w_VtailTip,vStab_cg40),
        				"vTailFin" => (w_VtailFin,finStab_cg40),
        				"mainLG" => (w_MainLG,cg_MainLG),
        				"noseLG" => (w_NoseLG,cg_NoseLG),
						"SeatRow_1" =>(w_SeatRow1,cg_SeatRow1),
						"SeatRow_2" => (w_SeatRow2,cg_SeatRow2),
						"engine"=> (w_engine,cg_engine),
						);

# ╔═╡ 34c83825-cca7-430c-a70c-09cd85d99852
WeightComponent_fuel=Dict("usableFuel"=> (UsableFuel,cg_fuel));

# ╔═╡ e01584c3-1a50-4b0e-8f6c-008312e6e945
weightComponent_OPEmpty=Dict("trappedFuel" =>(TrappedFuel,cg_fuel),
						"Crew" => (w_Crew,cg_SeatRow1));

# ╔═╡ a5ba9d65-2ba9-4328-ad81-ac426f91320c
WeightComponent_payload=Dict("Passenger1" => (w_passenger1,cg_SeatRow1),
						"Passenger2" => (w_passenger2,cg_SeatRow2),
						"BRS" => (w_BRS,cg_BRS));

# ╔═╡ 1dbe47ad-952c-4074-aac3-80e643099531
emptyW_component = sum(weight for (weight, pos_x) in values(weight_Empty))

# ╔═╡ bf9d769c-1918-46a2-904c-199da2adb044
OpEmpt_component=sum(weight for (weight, pos_x) in values(weightComponent_OPEmpty))

# ╔═╡ d9cad966-9d5f-4c1f-a75a-56a66cfb4c98
fuel_component = UsableFuel

# ╔═╡ af74f497-4752-42fd-9a85-9618b787df96
payload_component = sum(weight for (weight, pos_x) in values(WeightComponent_payload))

# ╔═╡ 6df33c5b-fe54-480c-9d57-a2e806be631e
sum_moments_emptyComp = sum(moment(weight, pos_x) for (weight, pos_x) in values(weight_Empty));

# ╔═╡ e241a14b-8340-45dd-9bc7-04d2b426198c
sum_moments_OpEmpt_Comp = sum(moment(weight, pos_x) for (weight, pos_x) in values(weightComponent_OPEmpty))

# ╔═╡ df0597a3-492b-4735-9497-90179942a882
sum_moments_fuel_Comp = sum(moment(fuel_component, 4.8));

# ╔═╡ 7bab3e29-2558-4a20-b092-6e8921e427d5
sum_moments_payload = sum(moment(weight, pos_x) for (weight, pos_x) in values(WeightComponent_payload));

# ╔═╡ 3d3f2ec4-299e-4936-9fec-18d0542e273d
x_cg_Empt_Comp = sum_moments_emptyComp/emptyW_component

# ╔═╡ 6a8e4835-5643-4b3c-b9b5-28e596cd1170
x_cg_OpEmpt_Comp = sum_moments_OpEmpt_Comp/OpEmpt_component

# ╔═╡ e64398d7-6aeb-40b5-b774-e9a7ef50ab79
x_cg_fuel_Comp = sum_moments_fuel_Comp/fuel_component

# ╔═╡ 6df55772-ea54-48f0-a577-bb0a372dcffa
x_cg_Passenger = sum_moments_payload/payload_component

# ╔═╡ 33a141a5-3e02-419a-be64-5d654578982d
begin
	moment1=sum_moments_emptyComp
	moment2=sum_moments_OpEmpt_Comp
	moment3=sum_moments_fuel_Comp
	moment4=sum_moments_payload
	
	x_cg1=x_cg_Empt_Comp
	x_cg2=x_cg_OpEmpt_Comp
	x_cg3=x_cg_fuel_Comp
	x_cg4=x_cg_Passenger
end;

# ╔═╡ 61d42a8a-cb21-4f10-a310-66a06d3b2565
function excursion(m1,m2,m3,m4,x1,x2,x3,x4)
	excursion_xcg=[m1/(m1/x1),(m2+m1)/((m2/x2)+(m1/x1)),(m3+m2+m1)/((m3/x3)+(m2/x2)+(m1/x1)),(m4+m3+m2+m1)/((m4/x4)+(m3/x3)+(m2/x2)+(m1/x1))]
	excursion_weight=[m1/x1,(m2/x2)+(m1/x1),(m3/x3)+(m2/x2)+(m1/x1),(m4/x4)+(m3/x3)+(m2/x2)+(m1/x1)]
	excursion_xcg,excursion_weight
end

# ╔═╡ 30b2ad6c-88bc-48f0-a436-4e155cff23f7
#Case 1 - 1234
case1cg,case1weight=excursion(moment1,moment2,moment3,moment4,x_cg1,x_cg2,x_cg3,x_cg4);

# ╔═╡ 0ed8b8b0-0674-4eff-bd68-d05f9b8c2a33
#Case 2 - 1243
case2cg,case2weight=excursion(moment1,moment2,moment4,moment3,x_cg1,x_cg2,x_cg4,x_cg3);

# ╔═╡ f589ca20-8af5-4164-8fba-1124ff131d35
#Case 3 - 1324
case3cg,case3weight=excursion(moment1,moment3,moment2,moment4,x_cg1,x_cg3,x_cg2,x_cg4);

# ╔═╡ f000648b-a70e-4600-b2f7-0af98922da15
#Case 4 - 1342
case4cg,case4weight=excursion(moment1,moment3,moment4,moment2,x_cg1,x_cg3,x_cg4,x_cg2);

# ╔═╡ c4748573-4944-4000-a21e-e4254dac6f07
#Case 5 - 1423
case5cg,case5weight=excursion(moment1,moment4,moment2,moment3,x_cg1,x_cg4,x_cg2,x_cg3);

# ╔═╡ 872a4079-7ef5-4501-8326-7f542fa671ed
#Case 6 - 1432
case6cg,case6weight=excursion(moment1,moment4,moment3,moment2,x_cg1,x_cg4,x_cg3,x_cg2);

# ╔═╡ 1f3a5f6a-d99f-48b3-8d62-ef2b4cfb4cfb
begin
	cg_excursionPlot = plot(ylabel = "Weight, kg", xlabel = "Longitudinal distance from the tip of the nose, m", 
		 			title = "CG Excursion Plot")
	plot!(case1cg, case1weight, label = "1234")
	plot!(case2cg, case2weight, label = "1243")
	plot!(case3cg, case3weight, label = "1324")
	plot!(case4cg, case4weight, label = "1342")
	plot!(case5cg, case5weight, label = "1423")
	plot!(case6cg,case6weight, label="1432")
end

# ╔═╡ 7eae14e0-8a1b-11eb-15f0-372c8c42804b
md"""## Static Margin Estimation

The forces depicted are the largest contributors to the longitudinal stability characteristics.


The static margin equation in a slightly modified form:
```math
\text{Static Margin} = \frac{l_h S_h}{\bar{c}S_w} \frac{C_{L_{\alpha_h}}}{C_{L_{\alpha_w}}} - \frac{\partial C_{m_{fus}}}{\partial C_L} - \frac{(x_{cg} - x_{25\%\ \text{MAC}})}{\bar{c}}
```
4 parameters are unknown after the sizing procedure:
1. The lift curve slope for the wing $C_{L_{\alpha_w}}$ 
2. The lift curve slope of the horizontal stabilizer $C_{L_{\alpha_h}}$ 
3. Derivative of pitching moment of fuselage (including other components) with respect to $C_L$ $\frac{\partial C_{m_{fus}}}{\partial C_L}$ 
4. Distance between wing aerodynamic center and the CG  $x_{cg} - x_{25\%\ \text{MAC}}$.

"""

# ╔═╡ d7449777-49c3-4acc-af6a-523fc6e67231
Canard_staticMargin(l_h,S_c,CLa_c,cbar,S_w,CLA_w,CmCL,x_cg,x_ac)=((l_h*S_c*CLa_c)/(cbar*S_w*CLA_w))+(CmCL)-((x_cg-x_ac)/cbar)

# ╔═╡ b89f03d2-0b78-45a9-9644-d5c1eb16f29d
md""" #### Downwash effect
"""

# ╔═╡ c77332d9-98eb-4cc5-a1c7-7fa60dd14dc3
begin
	downwashWing=0.41
	corrFactorWingDownwash=0.129
	CLwingIsolate=0.0688
	CLcanardIsolate=0.0693
	upwashCanard=0.05
end;

# ╔═╡ b620d985-d81b-466e-a489-6d6bf505f0c8
CLwing=CLwingIsolate*(1-(downwashWing*corrFactorWingDownwash))

# ╔═╡ 38fc9c2a-c84f-430e-aa2e-2b14e5cbe112
ClCanard_upwash=CLcanardIsolate*(1+upwashCanard)*S_c/S_W

# ╔═╡ 11dd1622-50c4-404e-88a2-c29c02760ca9
CLCanardWing=ClCanard_upwash+CLwing

# ╔═╡ e258ad9e-a39b-45c8-997b-d785977116fd
md"""### Fuselage Pitching Moment (Newton's Divided Differences Interpolation Polynomial) """

# ╔═╡ 55a66ce9-2c77-42dd-8aac-446cddb1274d
FusePitch(K_fus,w_fus,L_fus,S_w,cbar,CLA_w)=(K_fus*L_fus*(w_fus)^2)/(S_w*cbar*CLA_w)

# ╔═╡ fc926801-2060-4c9f-b103-466c30cb899a
getFuse(wingloc)=0.115+(0.57*(wingloc-0.1))+(5.75*(wingloc-0.1)*(wingloc-0.2))+((-24)*(wingloc-0.1)*(wingloc-0.2)*(wingloc-0.3))+(96.25*(wingloc-0.1)*(wingloc-0.2)*(wingloc-0.3)*(wingloc-0.4))+((-314.167)*(wingloc-0.1)*(wingloc-0.2)*(wingloc-0.3)*(wingloc-0.4)*(wingloc-0.5))+(890.2778*(wingloc-0.1)*(wingloc-0.2)*(wingloc-0.3)*(wingloc-0.4)*(wingloc-0.5)*(wingloc-0.6))

# ╔═╡ 5a22ad68-2241-4c8e-bfc5-bbaf9bf786e2
md"""### Tail volume parameters"""

# ╔═╡ cccce8d6-afa5-484f-8871-9106e71da354
#define moment arms
begin
	l_canard=abs(Mainwing_cg25-Canard_cg25)
	l_wingtip=abs(vStab_cg25-Mainwing_cg25)
	l_aftFin=abs(finStab_cg25-Mainwing_cg25)
end;

# ╔═╡ 84aedc8c-5a59-4e7a-8136-d209b16984bd
C_VT(L_vt,S_vt,b_w,S_w)=(L_vt*S_vt)/(b_w*S_w)

# ╔═╡ 87ad6166-a5f7-4fdd-9ca3-85ec1ac62fff
C_HT(L_ht,S_ht,cbar_w,S_w)=(L_ht*S_ht)/(cbar_w*S_w)

# ╔═╡ 217f7fb1-0cc4-4ead-8998-2fc5c13571a9
Volume_wingtip=C_VT(l_canard,S_wingtip,b_W,S_W)

# ╔═╡ 97c7bd4b-f860-4e66-bd5a-a901f9c014ee
Volume_aftFin=C_VT(l_aftFin,S_aftFin,b_W,S_W)

# ╔═╡ 8164635b-1ad6-4b74-8926-b90d6182cc69
Volume_Canard=C_HT(l_canard,S_c,mainWingMAC_c,S_W)

# ╔═╡ 995fb655-6e01-452b-91fd-93b5cb89a17e
md"""#### Value Checks"""

# ╔═╡ 67fc7cd4-afd1-4812-9e34-41527ca8e68a
testCmCL=FusePitch(getFuse(Mainwing_cg25/L_F),w_F,L_F,S_W,mainWingMAC_c,CLwing)

# ╔═╡ 8944cab7-3a9e-4573-93cc-3f605fcb545a
SM1=Canard_staticMargin(case1cg[1]-Canard_cg40,S_c,ClCanard_upwash,mainWingMAC_c,S_W,CLwing,testCmCL,case1cg[1],Mainwing_cg40)

# ╔═╡ d6562dfe-6656-494b-aae7-9807aec745f9
neutralPoint=(SM1/100)*mainWingMAC_c+case1cg[1]

# ╔═╡ Cell order:
# ╟─69b42df0-8ae2-11eb-0bba-1983308b31c6
# ╠═e76379e2-4d75-4b74-800d-8672941dc9a5
# ╠═7681f7f4-5830-4860-a67d-c2acd1ed8218
# ╠═8da00018-3cac-40d0-8d49-14a147467387
# ╟─0b5a24d0-8b00-11eb-224a-8b6fb1aff81a
# ╟─e8dad1e6-7477-42cc-b8e3-c518af7d9b52
# ╠═a3b5d8b0-89e2-11eb-1040-031e0142ca7c
# ╠═780dc91e-e6cf-4013-a04a-b35fa0fa9755
# ╠═c3824140-28d3-4f0d-8d56-3dbf42dca2cf
# ╟─c82ef9d0-89e5-11eb-02d1-db611f26e0b6
# ╟─3d325ff0-2a5e-4267-86f1-41c2cc25d7b1
# ╟─137918a0-8b06-11eb-0f23-2fd22e086911
# ╠═3053c570-89e3-11eb-1f51-8fb42324f651
# ╟─11ddb3ae-db3a-41b0-a77d-387f99b0e9a0
# ╠═09f81461-7713-41fc-a3b9-cc106018ccf5
# ╟─3a8b8e80-89e6-11eb-255d-df692399569f
# ╠═68795e80-89e6-11eb-04da-c9e66888d483
# ╟─3a4723e4-ec74-4d59-b1cd-4d1e99f2434e
# ╠═28ad10c1-678a-45e5-85b7-772a99108f0c
# ╟─11a520d0-89e6-11eb-2337-a5c4040b8013
# ╠═12d99410-89e4-11eb-1bbb-6b20dcf1678a
# ╠═be1b261a-be10-4c60-adad-36614e7b5827
# ╟─608bc750-8b06-11eb-2123-fb1b2a57a252
# ╠═30fe0cc4-7e57-49bc-89b2-ce3b00cc2a65
# ╠═9e1c4b9c-4352-47e0-be98-65cc599474ac
# ╠═cb11e4d7-233f-4779-b9ad-7059bff013c9
# ╠═b356c994-2314-491d-a93d-b5625be04036
# ╠═2a7232ae-70a5-4bee-9b63-6d9903701a40
# ╠═f90ac96f-200c-4c00-bb15-f24074865da4
# ╠═463f1e3b-365a-4311-a4db-bdbefa66564d
# ╠═5072dbe8-a88e-4891-8cb6-6a765d055dae
# ╠═d76e65a8-9e8f-4665-8fa8-52382d8dfbb2
# ╠═45d4c80a-5798-4451-a591-c1811ba15fed
# ╠═fc3217ef-7fc1-433a-a9b2-84cfda8f04d8
# ╟─2d4a5450-8b07-11eb-3b69-3dc27e505c50
# ╠═afaaa1f0-8a0f-11eb-00dc-47d7ecc444a7
# ╠═142c524a-3917-430d-aab8-1469dc8effa8
# ╠═aee47142-8ce8-4189-9bfd-3ee51fbb4cb1
# ╠═197916ee-fe63-4df2-869b-81c440d5ff84
# ╠═3e05470c-1161-4adc-9607-3638368a14d6
# ╠═10ca0d20-b99e-4b6e-a6b3-ecb95d1bf1b0
# ╠═2c683bb7-83d6-409d-850b-9f622cfeefe9
# ╠═f1ab1278-4ab5-423c-a773-5d2e874d06f7
# ╠═b9c58e91-11e8-47db-a331-14691993f212
# ╠═7a95efd5-9794-43cb-b6cc-970c0899f746
# ╟─9c13d810-8a13-11eb-07a5-3bcedbd77eac
# ╠═9b2da92a-d97c-485b-ab36-bc775a65a159
# ╟─7a540330-8a13-11eb-3e55-c15452e5004c
# ╠═ea34f410-8a14-11eb-1556-3b8c3ea0307d
# ╟─00d09cb2-8a15-11eb-0638-dffe4c995856
# ╟─a9ab5c00-8a18-11eb-1992-93bb7c57c029
# ╠═89bf9247-00c9-4b30-b328-6b1777d474a7
# ╟─4175e400-8a1a-11eb-305d-bf6a7ad893ed
# ╠═5b9711fa-4950-4512-9bec-14d08f594324
# ╠═b63575a7-d350-496e-a0a7-9653413bfb62
# ╟─84906350-8a1a-11eb-26b6-2324a98f390b
# ╠═934c246e-b0b7-4421-8545-a9e7b3d16bd3
# ╠═a8e2beb4-817f-4de7-a883-f6777c2ab73c
# ╟─3a64faf2-56cd-438a-a187-a213bcdfcd14
# ╠═edf063b2-54ea-46f5-9d13-854e5014657d
# ╠═34c83825-cca7-430c-a70c-09cd85d99852
# ╠═e01584c3-1a50-4b0e-8f6c-008312e6e945
# ╠═a5ba9d65-2ba9-4328-ad81-ac426f91320c
# ╠═1dbe47ad-952c-4074-aac3-80e643099531
# ╠═bf9d769c-1918-46a2-904c-199da2adb044
# ╠═d9cad966-9d5f-4c1f-a75a-56a66cfb4c98
# ╠═af74f497-4752-42fd-9a85-9618b787df96
# ╠═6df33c5b-fe54-480c-9d57-a2e806be631e
# ╠═e241a14b-8340-45dd-9bc7-04d2b426198c
# ╠═df0597a3-492b-4735-9497-90179942a882
# ╠═7bab3e29-2558-4a20-b092-6e8921e427d5
# ╠═3d3f2ec4-299e-4936-9fec-18d0542e273d
# ╠═6a8e4835-5643-4b3c-b9b5-28e596cd1170
# ╠═e64398d7-6aeb-40b5-b774-e9a7ef50ab79
# ╠═6df55772-ea54-48f0-a577-bb0a372dcffa
# ╠═33a141a5-3e02-419a-be64-5d654578982d
# ╠═61d42a8a-cb21-4f10-a310-66a06d3b2565
# ╠═30b2ad6c-88bc-48f0-a436-4e155cff23f7
# ╠═0ed8b8b0-0674-4eff-bd68-d05f9b8c2a33
# ╠═f589ca20-8af5-4164-8fba-1124ff131d35
# ╠═f000648b-a70e-4600-b2f7-0af98922da15
# ╠═c4748573-4944-4000-a21e-e4254dac6f07
# ╠═872a4079-7ef5-4501-8326-7f542fa671ed
# ╠═1f3a5f6a-d99f-48b3-8d62-ef2b4cfb4cfb
# ╟─7eae14e0-8a1b-11eb-15f0-372c8c42804b
# ╠═d7449777-49c3-4acc-af6a-523fc6e67231
# ╟─b89f03d2-0b78-45a9-9644-d5c1eb16f29d
# ╠═c77332d9-98eb-4cc5-a1c7-7fa60dd14dc3
# ╠═b620d985-d81b-466e-a489-6d6bf505f0c8
# ╠═38fc9c2a-c84f-430e-aa2e-2b14e5cbe112
# ╠═11dd1622-50c4-404e-88a2-c29c02760ca9
# ╟─e258ad9e-a39b-45c8-997b-d785977116fd
# ╠═55a66ce9-2c77-42dd-8aac-446cddb1274d
# ╠═fc926801-2060-4c9f-b103-466c30cb899a
# ╟─5a22ad68-2241-4c8e-bfc5-bbaf9bf786e2
# ╠═cccce8d6-afa5-484f-8871-9106e71da354
# ╠═84aedc8c-5a59-4e7a-8136-d209b16984bd
# ╠═87ad6166-a5f7-4fdd-9ca3-85ec1ac62fff
# ╠═217f7fb1-0cc4-4ead-8998-2fc5c13571a9
# ╠═97c7bd4b-f860-4e66-bd5a-a901f9c014ee
# ╠═8164635b-1ad6-4b74-8926-b90d6182cc69
# ╟─995fb655-6e01-452b-91fd-93b5cb89a17e
# ╠═67fc7cd4-afd1-4812-9e34-41527ca8e68a
# ╠═8944cab7-3a9e-4573-93cc-3f605fcb545a
# ╠═d6562dfe-6656-494b-aae7-9807aec745f9
# ╟─b79ef21d-e232-4c10-a0ba-6b4c54ad71aa
