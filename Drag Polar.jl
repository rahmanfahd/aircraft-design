### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ a2a72c58-9dd5-4e35-8fdd-a23c81b42739
begin 
	using AeroMDAO
	using Plots
	using PlutoUI
	plotlyjs()
end

# ╔═╡ 88d02510-af57-11eb-333b-73e3d9b214d9
md"""
# Trimmed drag polars for the whole aircraft
"""

# ╔═╡ 910f1a2d-f977-4a37-b54a-b3e465cfc996
md"### Fuselage drag"

# ╔═╡ af55a6ef-096c-4d7b-bc2a-9365ea1bfb58
CD0_fuse(C_f,f_LD,f_M,S_wetF,S)=C_F*F_LD*f_M*S_wet/S

# ╔═╡ 5e9c31a1-ec37-46b5-add9-7398d3bf68df
begin
	#C_f= #skin friction coef.
	#f_LD= #factor relating to length-to-diameter ratio
	#f_M= #factor relating to Mach no.
	#S_wetF= #wetted area of fuselage
	#S= #surface area
end

# ╔═╡ b5ffb132-c25f-48a5-8f1a-3d0230b3e787
function compute_skin_friction_drag(rho,V,L,miu)
	Re(rho,V,L,miu)=rho*V*L/miu
	#L is length of fuselage for fuselage, for tail it is the chord length
	
	if Re<200000
		C_friction=1.327/(sqrt(Re))
	end
	
	if Re>2000000
		C_friction=0.455/((log10(Re))^2.58)
	end
	
	C_friction
end

# ╔═╡ e0ebfab6-fca0-4b9a-8d0f-5106a35f4242
f_LtoD(L_f,D_f)=1+(60/((L_f/D_f)^3))+0.0025*(L_f/D_f)

# ╔═╡ 3a2567a1-29bd-4a44-8ce8-f1b983c7ec83
f_Mach(M)=1-0.08*M^1.45

# ╔═╡ 0d98227c-401e-4e56-bf54-c20b8d7bd6fa
md"### Wing, horizontal, vertical tail drags"

# ╔═╡ 06594da2-3cea-474d-9797-eafc0c4dfe81
C_D0(C_f, f_M, f_t, Swet, C_dmin, S)=C_f*f_M*f_t*(Swet/S)*((C_dmin/0.004)^0.4)         #obtain CDmin from Cd-Cl curve of airfoil, skin friction is similar to fuselage 

# ╔═╡ 51df3b06-5d94-4693-84e5-061e13de1902
f_t(t_cmax)=1+(2.7*t_cmax)+(100*(t_cmax^4)) #obtain 

# ╔═╡ d896f8e2-4d42-487d-82b9-392842ed8e00
#find CD of LERX --> can just make it an additional wing

# ╔═╡ 23381ccb-ed20-4d5b-b3e0-f034efaf5a4b
md"### Landing gear drag"

# ╔═╡ 2e758033-337a-49c6-90d2-babccbdda401
#fixed may incure 50% extra drag, fairings can reduce drag

# ╔═╡ 9c3b3453-0d4d-4bc8-9dee-d1132e34a62f
CD0_LG(CD_LG,S_LG,S)=CD_LG*S_LG/S

# ╔═╡ e9d7447f-c6a4-4f7c-811d-1a86f17b94b4
begin
	CD_LG=0.15#with fairings
end

# ╔═╡ 3142c8fc-3f2e-4dc1-b77e-c0aa81d28aee
md"### Strut drag"

# ╔═╡ 694cdd4c-c042-418b-932a-682bec0daf51
CD0_strut(CD0_Si,S_s,S)=CD0_Si*S_s/S

# ╔═╡ b67a3dad-29bc-45c8-b1e1-92a5c8eb8935
#struts with fairings (airfoil section) decreases drag significantly, but at a high cost

# ╔═╡ 4d5b962e-9301-47d0-a27d-6ad775c854b6
#refer to L13 P21 for CD of different shapes

# ╔═╡ a7865faf-383c-467e-83a5-b62615617a1c
md"### Drag polar at clean configuration"

# ╔═╡ abfe110e-dca1-4d5f-9046-0d06912ed401
#C_Dclean=CD0_clean+K*(CL_c)^2

# ╔═╡ 33dadd70-7e82-46a6-8100-91daf073f574
#CL_c is CL at cruise

# ╔═╡ Cell order:
# ╟─88d02510-af57-11eb-333b-73e3d9b214d9
# ╠═a2a72c58-9dd5-4e35-8fdd-a23c81b42739
# ╟─910f1a2d-f977-4a37-b54a-b3e465cfc996
# ╠═af55a6ef-096c-4d7b-bc2a-9365ea1bfb58
# ╠═5e9c31a1-ec37-46b5-add9-7398d3bf68df
# ╠═b5ffb132-c25f-48a5-8f1a-3d0230b3e787
# ╠═e0ebfab6-fca0-4b9a-8d0f-5106a35f4242
# ╠═3a2567a1-29bd-4a44-8ce8-f1b983c7ec83
# ╟─0d98227c-401e-4e56-bf54-c20b8d7bd6fa
# ╠═06594da2-3cea-474d-9797-eafc0c4dfe81
# ╠═51df3b06-5d94-4693-84e5-061e13de1902
# ╠═d896f8e2-4d42-487d-82b9-392842ed8e00
# ╟─23381ccb-ed20-4d5b-b3e0-f034efaf5a4b
# ╠═2e758033-337a-49c6-90d2-babccbdda401
# ╠═9c3b3453-0d4d-4bc8-9dee-d1132e34a62f
# ╠═e9d7447f-c6a4-4f7c-811d-1a86f17b94b4
# ╟─3142c8fc-3f2e-4dc1-b77e-c0aa81d28aee
# ╠═694cdd4c-c042-418b-932a-682bec0daf51
# ╠═b67a3dad-29bc-45c8-b1e1-92a5c8eb8935
# ╠═4d5b962e-9301-47d0-a27d-6ad775c854b6
# ╟─a7865faf-383c-467e-83a5-b62615617a1c
# ╠═abfe110e-dca1-4d5f-9046-0d06912ed401
# ╠═33dadd70-7e82-46a6-8100-91daf073f574
