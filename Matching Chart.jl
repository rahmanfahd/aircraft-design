### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ c695e3e0-2f3b-11eb-027f-ed0248d96007
using Plots

# ╔═╡ bd1b2930-7458-11eb-3483-71e2935f5945
begin
	using PlutoUI
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));
	alert(text=md"Alert!") = Markdown.MD(Markdown.Admonition("danger", "Alert!", [text]));
	definition(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("warning", "Definition", [text]));
	exercise(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("correct", "Exercise", [text]));
	correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]));
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));
	warning(text=md"Warning.") = Markdown.MD(Markdown.Admonition("warning", "Warning!", [text]));
	tip(text=md"Tip.") = Markdown.MD(Markdown.Admonition("warning", "Tip", [text]));
end;

# ╔═╡ 1b0fda70-7433-11eb-3fd1-5bde27831603
md"""
# Milestone 2: Matching Chart + Drag Polar estimation
"""

# ╔═╡ 4450d52a-bcc4-4a75-a56d-479e81ad53c8
plotlyjs()

# ╔═╡ 59bc0250-7463-11eb-0880-7348a2b01ad8
md"### Aircraft Parameters
The wing span length is set to $b = 8.1m$ and the wing area $S = 7m^2$.
Here we consider an aircraft with aspect ratio $AR = 8.67$, and an Oswald span
efficiency factor $e = 0.8$.
The zero-lift drag coefficient $C_{D_0}$ can be calculated by various methods, such
as regression, wetted area estimation, drag build-up, etc. Here we use a value
$C_{D_0} = 0.013$."

# ╔═╡ dca970c0-2f3b-11eb-21c6-9b2ceb7b62ca
begin #clean
CD0 = 13e-3
AR = 7
e = 0.8
end;

# ╔═╡ 6e4f4e40-7457-11eb-3561-f7458f6c733a
md"""
### Induced Drag Coefficient

```math
k = \frac{1}{\pi e AR}
```
"""

# ╔═╡ cb4cb52e-2f3b-11eb-0121-c92bc4b2b950
induced_drag_coefficient(e, AR) = 1 / (π * e * AR)

# ╔═╡ e19a16c0-2f3b-11eb-204b-a1d79f7a31ad
k = induced_drag_coefficient(e, AR)

# ╔═╡ 80ca4b10-7457-11eb-27d2-dd5fd4e77383
md"""
### Parabolic Drag Polar

```math
C_D = C_{D_0} + k\left(C_L - C_{L_{\alpha = 0}}\right)^2, \quad k = \frac{1}{\pi e AR}
```
"""

# ╔═╡ d701fde0-2f3b-11eb-345f-955af341b009
drag_polar(CD0, k, CL, CL0 = 0.) = CD0 + k * (CL - CL0)^2

# ╔═╡ 3aaa03d0-746d-11eb-2b50-dd705284a42f
md"Let's define a range of lift coefficients over which we would like to see the variation of the drag polar."

# ╔═╡ 46d54fa0-2f3c-11eb-2c81-c972cc10fc41
cls = -1.5:0.05:1.5

# ╔═╡ dfe1e4c0-746e-11eb-267e-3546c9416205
md"Here we consider an cambered airfoil with NACA $2412$, which has $C_{L_{\alpha = 0}} = 0.3$."

# ╔═╡ 19df47e0-746e-11eb-2b1b-a9b4a09db0a5
CL0_1 = 0.3

# ╔═╡ 3707e260-7463-11eb-17f7-073926ca3929
cds = drag_polar.(CD0, k, cls, CL0_1);

# ╔═╡ 17dc7840-2f3c-11eb-26d4-67e3a57e9730
test_plot = plot(cds, cls, 
	 			 label = "Clean",
				 xlabel = "CD", ylabel = "CL", title = "Drag Polar")

# ╔═╡ 45a4c000-7476-11eb-3b15-7795df62140c
# savefig(test_plot, "Drag Polar")

# ╔═╡ 06d40dd1-1244-40df-9ac4-e81ea7f37c1a
begin #for cruise
CD0_2 = 0.014
CL0_2 = 0.093
cds_2 = drag_polar.(CD0_2, k, cls, CL0_2)
end;

# ╔═╡ 75c452c3-cad2-472e-9949-108aa62b53e5
begin #landing
CD0_3 = 0.013
CL0_3 = 0.04
cds_3 = drag_polar.(CD0_3, k, cls, CL0_3)
end;

# ╔═╡ 3ebcb070-746e-11eb-2e5c-8129abd1179e
begin
	plot(cds, cls,
	label = "Clean",
	xlabel = "CD", ylabel = "CL", title = "Drag Polar")
	plot!(cds_2, cls, marker = :dot,
	label = "CD0 = $CD0_2, CL0 = $CL0_2")
	plot!(cds_3, cls, marker = :dot,
	label = "CD0 = $CD0_3, CL0 = $CL0_3")

end

# ╔═╡ 4eb37530-7433-11eb-3149-afb0f1d19b2c
md"""
## Constraints Analysis
The constraints of the initial sizing procedure are determined by equating the thrust-to-weight ratio $(T/W)$ to a function of the wing loading $(W/S)$ for different flight conditions.

```math
(T/W) = f(W/S)
```

The objective is to obtain the maximum $(W/S)$ and the minimum $(T/W)$ to obtain the optimum size and propulsion. These will allow determination of the wing area $S_w$ and required thrust, once the MTOW has been determined. 

*Note*: We use $S$ and $S_w$ interchangeably for brevity, differentiating in context.

Here we define a range of wing loading values we consider for our aircraft.
"""

# ╔═╡ 614a1050-7433-11eb-0821-41c5a3438a0f
wing_loadings = 5:1:2000;

# ╔═╡ 9831b280-7433-11eb-30f9-7b6994bc6653
md"""
### Power Loading

For engines or motors with propellers, the relevant conversion accounting for speed and efficiency of the propeller is as follows:

\begin{align}
	(P/W) = \frac{(T/W) V}{\eta_\text{prop}}
\end{align}
"""

# ╔═╡ 9be5449e-7433-11eb-103d-8f4adda19729
η_prop_FW = 0.8;

# ╔═╡ 93acedb0-7433-11eb-23cf-e76771b143e2
power_loading(tbW, V, η_p) = tbW * V / η_p

# ╔═╡ 31f691a0-743a-11eb-2d56-a5a00e193c49
md"""### Stall Speed

Dynamic pressure:

```math
q = \frac{1}{2} \rho V^2
```

Stall speed:
```math
(W/S)^{FW}_\text{stall} = \frac{1}{2} \rho V^2_\text{stall} C_{L_\max}
```
"""

# ╔═╡ b979b830-2f3b-11eb-2c1f-95035ea2a15b
dynamic_pressure(ρ, V) = 1/2 * ρ * V^2

# ╔═╡ 3d9c49f2-743a-11eb-0cd9-a32988a847f4
wing_loading_stall_speed(V_stall, CL_max, ρ = 1.225) = dynamic_pressure(ρ, V_stall) * CL_max

# ╔═╡ 338b05c0-7465-11eb-1ef1-75134695ef8e
V_stall = 31 #why did they put 97.5?, 61 knots in prev. FAR23 req.

# ╔═╡ 34f56b30-7465-11eb-35b7-b3147697cc9d
CL_max = 1.8

# ╔═╡ 45ed0ae0-743a-11eb-34b1-8dc823f25349
n = 20

# ╔═╡ 426a3e30-7465-11eb-3956-f7d1b0e8630f
stalls = fill(wing_loading_stall_speed(V_stall, CL_max), n);

# ╔═╡ 1c9f3d20-746c-11eb-15c5-5f0e9ada6740
md"For the small-scale aircraft, the $(T/W)$ ratios may exceed $1$ with oversized
motors."

# ╔═╡ 30610740-746b-11eb-103a-97a1a677aa08
tbWs_stall = range(0, 5.; length = n)

# ╔═╡ 426cd640-7465-11eb-13b6-cb0a8c77df0a
pbWs_stall = power_loading.(tbWs_stall, V_stall, CL_max);

# ╔═╡ bc98aa10-8bc2-11eb-3761-275f8c315941
pbWs_stall

# ╔═╡ 20ee4160-746b-11eb-0707-61ac484435ea
plot(stalls, tbWs_stall, label = "Stall Speed", 
	 ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²")

# ╔═╡ 2b7cae61-0f9d-4f4a-94e3-318a679d6d26
md"""
### Take-off
"""


# ╔═╡ 00ef41ef-9241-4331-971e-db20e6c68467
takeoff_condition(CL_max,TOP,wing_load)=(1/(CL_max*TOP))*wing_load

# ╔═╡ 401133b0-81db-4419-bf38-78dd836c23d0
begin
	CL_takeoff=2
	TOP=650
	V_to=V_stall*1.1
end;

# ╔═╡ 0c098d7d-a67e-4053-8f07-738e29eee056
tbw_takeoff=takeoff_condition.(CL_takeoff,TOP,wing_loadings)

# ╔═╡ 1177e156-a184-4dda-bb63-81b76c097548
pbw_takeoff=power_loading.(tbw_takeoff, V_to, η_prop_FW)

# ╔═╡ 72b35b03-ff38-4b0d-ac51-65ef7d45cb7f
begin
	Stall_takeoff_chart = plot(ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart (Fixed Wing)")
	plot!(stalls, tbWs_stall, label = "Stall Speed")
	#plot!(wing_loadings, tbw_takeoff, label = "Takeoff")
	plot!(wing_loadings,tbw_takeoff,label="takeoff power")
end

# ╔═╡ b5aa6a47-1e0b-4a8f-877b-7e69a998f679
md"""
### Landing
"""


# ╔═╡ e1341b5a-9751-4cb9-954d-947959795225
begin
	CLmax_land=2.5
	safety_marg=0.6
	S_a=183
	g=9.18
	MTOW=2541.309934319981;
	Mland=MTOW-(MTOW*0.31135388287326593/1.1)
	WLW0=Mland/MTOW
	V_land=V_stall*1.3
	S_fl=750
end;

# ╔═╡ 9fe7102e-0c47-4e3e-98ec-c0fa209e1bbb
landing_condition(g, CLmax_land, S_fl, S_a, safety_marg)=((g*CLmax_land)/5)*((S_fl*safety_marg)-S_a)

# ╔═╡ 1970ac8e-2eb8-463f-93d6-ff9f826ef178
landing_condition(g, CLmax_land, S_fl, S_a, safety_marg)

# ╔═╡ 7ed46d06-3118-4ef0-b76f-44e5b1e0857b
landing_sls=(1/WLW0)*landing_condition(g, CLmax_land, S_fl, S_a, safety_marg)

# ╔═╡ 6cb0fe34-ad41-472b-9847-1ae42c3679c9
wbs_landing=fill(landing_sls,n);

# ╔═╡ 82d3f856-20ef-42ef-afa5-1fb6a2f7781c
tbWs_landing = range(0, 5.; length = n);

# ╔═╡ 0c8b36b7-dd69-4be2-ac26-a89b53a7bd30
pbWs_landing = power_loading.(tbWs_landing, V_land, η_prop_FW);

# ╔═╡ 027f830f-9591-4024-81c4-15d3df9a40f4
begin
	Stall_land_chart = plot(ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart (Fixed Wing)")
	plot!(stalls, tbWs_stall, label = "Stall Speed")
	plot!(wing_loadings, tbw_takeoff, label = "Takeoff")
	plot!(wbs_landing, tbWs_landing, label = "Landing")
end

# ╔═╡ 13c57067-22a6-4f40-a52b-3c97ca09c22c
stalls;

# ╔═╡ 752bf020-7433-11eb-0393-d3ab1d104f47
md"""
### Cruise

The matching equation for cruise is obtained from the cruise conditions $T = D,~L = W$ and substituting into the drag polar relation.

```math
\begin{align}
	(T/W)^\text{FW}_\text{cruise} = \frac{q C_{D_0}}{(W/S)} + \frac{k}{q}(W/S)
\end{align}
```
"""

# ╔═╡ 7f11a8f0-7433-11eb-20e8-3b8ddaee4060
thrust_to_weight_fw_cruise(q, k, CD0, wing_loading) = ((1/(0.909/1.225))^0.6)*0.990016*(q * CD0 / (wing_loading) + k / q * wing_loading)

# ╔═╡ 85c91220-7468-11eb-114d-51f4af036910
begin
	V_cruise = 77 #my input:77m/s
	ρ = 0.905 #1.31
	density_ratio_cruise=ρ/1.225
	q = dynamic_pressure(ρ, V_cruise)
	k_cruise=induced_drag_coefficient(0.65,AR)
	weightFrac_cruise=0.990016
end;

# ╔═╡ 839d4b90-7433-11eb-2273-79686fbd7d7e
begin
	tbWs_cruise = thrust_to_weight_fw_cruise.(q, k, CD0_2, wing_loadings)
	pbWs_cruise = power_loading.(tbWs_cruise, V_cruise, η_prop_FW)
end;

# ╔═╡ dc76e9af-c578-4f8c-970c-800e2a7877fa
cruise_condition(wing_load,q,CD0,k)=(q*CD0/wing_load)+(k*wing_load/q)

# ╔═╡ cef05bca-8384-4bb0-8df8-3a8b2cdfd3bf
tbw_cruise=1/density_ratio_cruise^0.6 * weightFrac_cruise* cruise_condition.(wing_loadings,q,CD0,k_cruise)

# ╔═╡ 39e74b9b-abe4-4c13-9cb0-38851886907f
pbw_cruise=power_loading.(tbw_cruise, V_cruise, η_prop_FW);

# ╔═╡ 1cc66961-edd1-480b-951d-2eb96da19856
plot(wing_loadings, tbw_cruise, label = "Cruise", 
	 ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²")

# ╔═╡ 59cc1dfd-2394-448d-8120-1e0b702715eb
begin
	Stall_land_cruise_chart = plot(ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart (Fixed Wing)")
	plot!(stalls, tbWs_stall, label = "Stall Speed")
	plot!(wing_loadings, tbw_takeoff, label = "Takeoff")
	plot!(wbs_landing, tbWs_landing, label = "Landing")
	plot!(wing_loadings,tbw_cruise,label="Cruise")
end

# ╔═╡ efbbc3f0-7439-11eb-161d-3166990ea8f1
md"""
### Climb
"""

# ╔═╡ fcaae67d-f693-42e9-a4d9-8f1cf9b45a6e
climb_condition(k_s, CD0, CL_max, K, G)=((k_s^2)*CD0/CL_max)+((CL_max/(k_s^2))*k)+G;

# ╔═╡ 00a688f5-fca3-4b6a-967d-0245917cc0da
function thrust_corr_climb(k_s, CD0, CL_max, K, G, weight_factor, MCT=false)
	
	MCT_factor=ifelse(MCT, 1/0.94, 1)
	
	(1/0.8)*MCT_factor*weight_factor*climb_condition(k_s, CD0, CL_max, K, G)
end

# ╔═╡ 44b52b65-ff5f-48df-89d5-e40b368deece
begin
	CD0_climb=CD0
	CL_max_climb=2.2
end;

# ╔═╡ 26b2336a-7a75-4ff6-842b-83c0e7d257cb
md"""
#### Takeoff climb
"""

# ╔═╡ 533111bd-b958-43c6-83ba-b3c19973e5a5
begin
	k_s_takeoff=1.1
	G_takeoff=0.083
	CD0_takeoff=CD0
	k_takeoff=induced_drag_coefficient(0.85, AR)
	weight_fact1=1
	MCT_takeoff=false
	
	takeoff_climbs=fill(thrust_corr_climb(k_s_takeoff,CD0_takeoff,CL_max_climb,k_takeoff,G_takeoff,weight_fact1,MCT_takeoff),length(wing_loadings))
end;

# ╔═╡ ef4a6911-1ed0-4ed3-b6ea-16d9ca443da1
md"""
#### Transition climb
"""

# ╔═╡ e3eb9744-6ae1-4a7b-ae13-cea30c5d5d48
begin
	k_s_transition=1.1
	G_transition=0
	CD0_transition=CD0
	k_transition=induced_drag_coefficient(0.75,AR)
	weight_fact2=0.99
	MCT_transition=false
	
	transition_climb=fill(thrust_corr_climb(k_s_transition,CD0_transition,CL_max_climb,k_transition,G_transition,weight_fact2,MCT_transition),length(wing_loadings))
end;

# ╔═╡ 5ca80935-8f66-45c7-ab31-b61dadc0168d
md"""
#### Second climb
"""

# ╔═╡ 30570a80-6945-4b42-bf61-e35d4cde78a3
begin
	k_s_second=1.1
	G_second=0.083
	CD0_second=CD0
	k_second=induced_drag_coefficient(0.85,AR)
	weight_fact3=0.98
	MCT_second=false
	
	second_climb=fill(thrust_corr_climb(k_s_second,CD0_second,CL_max_climb,k_second,G_second,weight_fact3,MCT_second),length(wing_loadings))
end;

# ╔═╡ 34eb5b06-8be0-4c71-8d65-be7f4d9eaff9
md"""
#### Enroute climb
"""

# ╔═╡ 673cec13-25aa-41be-a98e-80ff4cd15d6f
begin
	k_s_enroute=1.2
	G_enroute=0.083
	CD0_enroute=CD0
	k_enroute=induced_drag_coefficient(0.85,AR)
	weight_fact4=1
	MCT_enroute=true
	
	enroute_climb=fill(thrust_corr_climb(k_s_enroute,CD0_enroute,CL_max_climb,k_enroute,G_enroute,weight_fact4,MCT_enroute),length(wing_loadings))
end;

# ╔═╡ 71780241-ffb3-4115-8821-4f4843e372ec
md"""
#### Balked landing climb
"""

# ╔═╡ d0caf29c-a624-4612-8369-3175be159e98
begin
	k_s_balked=1.5
	G_balked=0.03
	CD0_balked=CD0
	k_balked=induced_drag_coefficient(0.75,AR)
	weight_fact5=1
	MCT_balked=false
	
	balked_climb=fill(thrust_corr_climb(k_s_balked,CD0_balked,CL_max_climb,k_balked,G_balked,weight_fact5,MCT_balked),length(wing_loadings))
end;

# ╔═╡ d27f356b-f728-40f6-9af1-0ad6e3943c8e
begin
	climb_chart = plot(ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart (climb)")
	plot!(wing_loadings,takeoff_climbs, label="Climb 1")
	plot!(wing_loadings,transition_climb, label="Climb 2")
	plot!(wing_loadings,second_climb, label="Climb 3")
	plot!(wing_loadings,enroute_climb, label="Climb 4")
	plot!(wing_loadings,balked_climb, label="Climb 5")
end

# ╔═╡ 6baa7798-7b9f-48b1-8dc3-3bbc4b82980d
begin
	match_chart = plot(ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart (Fixed Wing)")
	plot!(stalls, tbWs_stall, label = "Stall Speed")
	plot!(wing_loadings, tbw_takeoff, label = "Takeoff")
	plot!(wbs_landing, tbWs_landing, label = "Landing")
	plot!(wing_loadings,tbw_cruise,label="Cruise")
	plot!(wing_loadings,takeoff_climbs, label="Climb 1")
	plot!(wing_loadings,transition_climb, label="Climb 2")
	plot!(wing_loadings,second_climb, label="Climb 3")
	plot!(wing_loadings,enroute_climb, label="Climb 4")
	plot!(wing_loadings,balked_climb, label="Climb 5")
end

# ╔═╡ 4f6a3de0-743a-11eb-109b-63f93165bd36
md"""
### Service Ceiling
The service ceiling is the altitude at which the maximum rate of climb is $0.001~m/s$, so we re-use the climb equation with this value.
"""

# ╔═╡ bbe43fc0-746c-11eb-1435-d31af1391f71
begin
	RoC_ceiling = 0.001
	density_ceiling=0.89469763258
	weight_ratio_ceiling=0.718339816991928
	k_ceiling=k_cruise
end;

# ╔═╡ 8bd45fb1-9056-4a68-914c-14cabf344e2e
ceiling_condition(RoC_ceiling,CD0_2, k)=RoC_ceiling*sqrt(2*CD0_2*k)

# ╔═╡ dc2d5cf4-dc53-43bd-a188-ad06c064b270
best_climb_rate(density,wing_load,k,CD0)=sqrt((2/density)*wing_load*sqrt(k/(3*CD0)))

# ╔═╡ c8d0da8e-5fcf-4bed-a5af-3c4fa03ea177
best_VRoC=best_climb_rate.(density_ceiling,wing_loadings,k_ceiling,CD0_2)

# ╔═╡ ed7768ff-e274-4f0e-912e-353c35a720ed
begin
	tbWs_ceiling=fill((((1.225/density_ceiling)^0.6))*weight_ratio_ceiling*ceiling_condition(RoC_ceiling,CD0_2, k_ceiling),length(wing_loadings))
	pbWs_Ceiling=power_loading.(tbWs_ceiling, best_VRoC, η_prop_FW)
end;

# ╔═╡ 0962b6c0-af94-4582-8986-92cea23c030a
begin
	match_chart2 = plot(ylabel = "(T/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart")
	plot!(stalls, tbWs_stall, label = "Stall Speed")
	plot!(wing_loadings, tbw_takeoff, label = "Takeoff")
	plot!(wbs_landing, tbWs_landing, label = "Landing")
	plot!(wing_loadings,tbw_cruise,label="Cruise")
	plot!(wing_loadings,takeoff_climbs, label="Climb 1")
	plot!(wing_loadings,transition_climb, label="Climb 2")
	plot!(wing_loadings,second_climb, label="Climb 3")
	plot!(wing_loadings,enroute_climb, label="Climb 4")
	plot!(wing_loadings,balked_climb, label="Climb 5")
	plot!(wing_loadings,tbWs_ceiling,label="Ceiling")
end

# ╔═╡ 624bebc0-743a-11eb-1832-ddee60ff70b5
md"""
## Matching Charts
"""

# ╔═╡ 66e263d0-743a-11eb-0259-bd958c5897d1
begin
	fw_chart = plot(ylabel = "(P/W), W/N", xlabel = "(W/S), N/m²", 
		 			title = "Matching Chart")
	plot!(stalls, pbWs_stall, label = "Stall Speed")
	plot!(wing_loadings, tbw_cruise, label = "Cruise")
	#plot!(wing_loadings, pbWs_fw_climb, label = "Fixed-Wing Climb")
	plot!(wing_loadings, pbWs_Ceiling, label = "Ceiling")
	plot!(wbs_landing, pbWs_landing, label = "Landing")
	plot!(wing_loadings,takeoff_climbs, label="Climb 1")
	plot!(wing_loadings,transition_climb, label="Climb 2")
	plot!(wing_loadings,second_climb, label="Climb 3")
	plot!(wing_loadings,enroute_climb, label="Climb 4")
	plot!(wing_loadings,balked_climb, label="Climb 5")
	plot!(wing_loadings, pbw_takeoff, label = "Takeoff")
end

# ╔═╡ 43e98480-75c0-11eb-1807-f5c025c1b476
md"Now that we have the $(W/S)$ and $(T/W)$ or $(P/W)$ values, we can obtain the reference wing area $S_w$ and required thrust $T$ or power $P$ by using the maximum takeoff weight $W_0$ obtained from the initial weight estimation procedure."

# ╔═╡ Cell order:
# ╟─1b0fda70-7433-11eb-3fd1-5bde27831603
# ╠═4450d52a-bcc4-4a75-a56d-479e81ad53c8
# ╟─59bc0250-7463-11eb-0880-7348a2b01ad8
# ╠═dca970c0-2f3b-11eb-21c6-9b2ceb7b62ca
# ╟─6e4f4e40-7457-11eb-3561-f7458f6c733a
# ╠═cb4cb52e-2f3b-11eb-0121-c92bc4b2b950
# ╠═e19a16c0-2f3b-11eb-204b-a1d79f7a31ad
# ╟─80ca4b10-7457-11eb-27d2-dd5fd4e77383
# ╠═d701fde0-2f3b-11eb-345f-955af341b009
# ╟─3aaa03d0-746d-11eb-2b50-dd705284a42f
# ╠═46d54fa0-2f3c-11eb-2c81-c972cc10fc41
# ╟─dfe1e4c0-746e-11eb-267e-3546c9416205
# ╠═19df47e0-746e-11eb-2b1b-a9b4a09db0a5
# ╠═3707e260-7463-11eb-17f7-073926ca3929
# ╠═c695e3e0-2f3b-11eb-027f-ed0248d96007
# ╠═17dc7840-2f3c-11eb-26d4-67e3a57e9730
# ╠═45a4c000-7476-11eb-3b15-7795df62140c
# ╠═06d40dd1-1244-40df-9ac4-e81ea7f37c1a
# ╠═75c452c3-cad2-472e-9949-108aa62b53e5
# ╠═3ebcb070-746e-11eb-2e5c-8129abd1179e
# ╟─4eb37530-7433-11eb-3149-afb0f1d19b2c
# ╠═614a1050-7433-11eb-0821-41c5a3438a0f
# ╟─9831b280-7433-11eb-30f9-7b6994bc6653
# ╠═9be5449e-7433-11eb-103d-8f4adda19729
# ╠═93acedb0-7433-11eb-23cf-e76771b143e2
# ╟─31f691a0-743a-11eb-2d56-a5a00e193c49
# ╠═b979b830-2f3b-11eb-2c1f-95035ea2a15b
# ╠═3d9c49f2-743a-11eb-0cd9-a32988a847f4
# ╠═338b05c0-7465-11eb-1ef1-75134695ef8e
# ╠═34f56b30-7465-11eb-35b7-b3147697cc9d
# ╠═45ed0ae0-743a-11eb-34b1-8dc823f25349
# ╠═426a3e30-7465-11eb-3956-f7d1b0e8630f
# ╟─1c9f3d20-746c-11eb-15c5-5f0e9ada6740
# ╠═30610740-746b-11eb-103a-97a1a677aa08
# ╠═426cd640-7465-11eb-13b6-cb0a8c77df0a
# ╠═bc98aa10-8bc2-11eb-3761-275f8c315941
# ╠═20ee4160-746b-11eb-0707-61ac484435ea
# ╟─2b7cae61-0f9d-4f4a-94e3-318a679d6d26
# ╠═00ef41ef-9241-4331-971e-db20e6c68467
# ╠═401133b0-81db-4419-bf38-78dd836c23d0
# ╠═0c098d7d-a67e-4053-8f07-738e29eee056
# ╠═1177e156-a184-4dda-bb63-81b76c097548
# ╠═72b35b03-ff38-4b0d-ac51-65ef7d45cb7f
# ╟─b5aa6a47-1e0b-4a8f-877b-7e69a998f679
# ╠═e1341b5a-9751-4cb9-954d-947959795225
# ╠═9fe7102e-0c47-4e3e-98ec-c0fa209e1bbb
# ╠═1970ac8e-2eb8-463f-93d6-ff9f826ef178
# ╠═7ed46d06-3118-4ef0-b76f-44e5b1e0857b
# ╠═6cb0fe34-ad41-472b-9847-1ae42c3679c9
# ╠═82d3f856-20ef-42ef-afa5-1fb6a2f7781c
# ╠═0c8b36b7-dd69-4be2-ac26-a89b53a7bd30
# ╠═027f830f-9591-4024-81c4-15d3df9a40f4
# ╠═13c57067-22a6-4f40-a52b-3c97ca09c22c
# ╟─752bf020-7433-11eb-0393-d3ab1d104f47
# ╠═7f11a8f0-7433-11eb-20e8-3b8ddaee4060
# ╠═85c91220-7468-11eb-114d-51f4af036910
# ╠═839d4b90-7433-11eb-2273-79686fbd7d7e
# ╠═dc76e9af-c578-4f8c-970c-800e2a7877fa
# ╠═cef05bca-8384-4bb0-8df8-3a8b2cdfd3bf
# ╠═39e74b9b-abe4-4c13-9cb0-38851886907f
# ╠═1cc66961-edd1-480b-951d-2eb96da19856
# ╠═59cc1dfd-2394-448d-8120-1e0b702715eb
# ╟─efbbc3f0-7439-11eb-161d-3166990ea8f1
# ╠═fcaae67d-f693-42e9-a4d9-8f1cf9b45a6e
# ╠═00a688f5-fca3-4b6a-967d-0245917cc0da
# ╠═44b52b65-ff5f-48df-89d5-e40b368deece
# ╟─26b2336a-7a75-4ff6-842b-83c0e7d257cb
# ╠═533111bd-b958-43c6-83ba-b3c19973e5a5
# ╟─ef4a6911-1ed0-4ed3-b6ea-16d9ca443da1
# ╠═e3eb9744-6ae1-4a7b-ae13-cea30c5d5d48
# ╟─5ca80935-8f66-45c7-ab31-b61dadc0168d
# ╠═30570a80-6945-4b42-bf61-e35d4cde78a3
# ╟─34eb5b06-8be0-4c71-8d65-be7f4d9eaff9
# ╠═673cec13-25aa-41be-a98e-80ff4cd15d6f
# ╟─71780241-ffb3-4115-8821-4f4843e372ec
# ╠═d0caf29c-a624-4612-8369-3175be159e98
# ╠═d27f356b-f728-40f6-9af1-0ad6e3943c8e
# ╠═6baa7798-7b9f-48b1-8dc3-3bbc4b82980d
# ╟─4f6a3de0-743a-11eb-109b-63f93165bd36
# ╠═bbe43fc0-746c-11eb-1435-d31af1391f71
# ╠═8bd45fb1-9056-4a68-914c-14cabf344e2e
# ╠═dc2d5cf4-dc53-43bd-a188-ad06c064b270
# ╠═c8d0da8e-5fcf-4bed-a5af-3c4fa03ea177
# ╠═ed7768ff-e274-4f0e-912e-353c35a720ed
# ╠═0962b6c0-af94-4582-8986-92cea23c030a
# ╟─624bebc0-743a-11eb-1832-ddee60ff70b5
# ╠═66e263d0-743a-11eb-0259-bd958c5897d1
# ╟─43e98480-75c0-11eb-1807-f5c025c1b476
# ╟─bd1b2930-7458-11eb-3483-71e2935f5945
