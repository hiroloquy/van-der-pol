reset

#=================== Parameter ====================
# mu = 1.			# Coefficient of VDP equation
dt = 0.004		# Time step [s]
dh = dt/6.		# Coefficient of Runge-Kutta 4th
lim1 = 60		# Stop time
end = 100		# Time limit [s]
lim2 = end/dt	# Number of calculation
cut = 500		# Decimation

#=================== Function ====================
f1(a, b) = b
f2(a, b) = mu * (1 - a**2) * b - a

title(t, mu) = sprintf("{/Times:Italic t} = %.1f\n{/symbol:Italic m} = %.1f", t, mu)

#=================== Setting ====================
set term gif animate delay 4 size 1280,720
filename = "vdp_mu_10patterns.gif"
set output "van der Pol equation 2.gif"

set nokey
L = 8.0
set xr[-L:L]
set yr[-L:L]
set xl "{/Times:Italic=22 x}({/Times:Italic=22 t})" font 'Times New Roman, 22'
set yl "{/Times:Italic=22 x}'({/Times:Italic=22 t})" font 'Times New Roman, 22'
set tics font 'Times New Roman,18'
set xtics 2
set ytics 2

set size ratio 1
unset grid

#=================== Plot ====================
do for [j=0:50:5]{
	# Change the coefficient of VDP equation
	if(j==0){
		mu = 0.1
	} else {
		mu = j/10.
	}

	# Initial value
	x = 0.1		# x(t)
	y = 0.		# x'(t)
	t = 0.

	position = sprintf("(%.1f, %d)", x, y)

	# Draw initiate state for lim1 steps
	do for [i = 1:lim1] {
		# Display time and mu
		set label 1 right title(t, mu) font 'Times New Roman, 22' at graph 0.98, 0.95
		
    	# Display coordinates of N points
		if(i < lim1*0.8){
			set label 2 left position font 'Times New Roman, 14' at x+0.2, y+0.2
		} else {
			if(i==lim1*0.8){
				unset label 2
			}
		}

		set arrow 1 from -L, 0 to L, 0 lc -1 lw 2 back
		set arrow 2 from 0, -L to 0, L lc -1 lw 2 back
		set object 1 circle at 0, 0 size 2 fc rgb 'black' fs solid behind
		set object 2 circle at 0, 0 size 1.95 fc rgb 'white' fs solid behind
		set object 3 circle at x, y size 0.04 fc rgb 'black' fs solid back
		set object 4 circle at x, y size 0.02 fc rgb 'red' fs solid front

		plot 1/0
	}

	# Update for lim2 steps
	do for [i = 1:lim2] {
		t = t + dt

		# Calculate using Runge-Kutta 4th
		k11 = f1(x, y)
		k12 = f2(x, y)
		k21 = f1(x + dt*k11/2.,	y + dt*k12/2.)
		k22 = f2(x + dt*k11/2.,	y + dt*k12/2.)
		k31 = f1(x + dt*k21/2.,	y + dt*k22/2.)
		k32 = f2(x + dt*k21/2.,	y + dt*k22/2.)
		k41 = f1(x + dt*k31,	y + dt*k32)
		k42 = f2(x + dt*k31,	y + dt*k32)

		x = x + dh * (k11 + 2*k21 + 2*k31 + k41)
		y = y + dh * (k12 + 2*k22 + 2*k32 + k42)

		# Time and mu
		set label 1 title(t, mu)

		# Plot
		set object i+3 size 0.003 behind
		set object 3 circle at x, y
		set object i+4 circle at x, y size 0.02 fc rgb 'red' fs solid front

		if(i%cut==0){
			plot 1/0
		}
	}

	# Pause for lim1 steps
	do for [i=1:lim1] {
		plot 1/0
	}
}
set out