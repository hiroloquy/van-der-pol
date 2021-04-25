reset

#=================== Setting ====================
set nokey
L = 5.0
set xr[-L:L]
set yr[-L:L]
set xl "{/Times:Italic=18 x}({/Times:Italic=18 t})" font 'Times New Roman, 18'
set yl "{/Times:Italic=18 x}'({/Times:Italic=18 t})" font 'Times New Roman, 18'
set tics font 'Times New Roman,14'
set xtics 1
set ytics 1
set size ratio 1
unset grid

# Output GIF file
set term gif animate delay 4 size 1280,720
set output sprintf("vdp_6x_mu=%0.2f.gif", mu)

#=================== Parameter ====================
mu = 1.         # Coefficient of VDP equation
dt = 0.001      # Time step [s]
dh = dt/6.      # Coefficient of Runge-Kutta 4th
lim1 = 70       # Stop time
end = 30        # Time limit [s]
lim2 = end/dt   # Number of calculation
cut = 100       # Decimation

off = 0.15      # Offset
r = 0.08        # Size of points

N    = 6        # Number of points (array size)
array x[N]      # Position of points
array y[N]

# Color of points
array c[N] = ["red", "royalblue", "spring-green", \
              "dark-pink", "grey80", "dark-orange"]

#=================== Function ====================
#Van der Pol equation
f1(x, y)   = y
f2(x, y)   = mu * (1 - x**2) * y - x

#Runge-Kutta 4th order method
rk4x(x, y) = (k1 = f1(x, y),\
              k2 = f1(x + dt*k1/2, y + dt*k1/2),\
              k3 = f1(x + dt*k2/2, y + dt*k2/2),\
              k4 = f1(x + dt*k3, y + dt*k3),\
              dh * (k1 + 2*k2 + 2*k3 + k4))
rk4y(x, y) = (k1 = f2(x, y),\
              k2 = f2(x + dt*k1/2, y + dt*k1/2),\
              k3 = f2(x + dt*k2/2, y + dt*k2/2),\
              k4 = f2(x + dt*k3, y + dt*k3),\
              dh * (k1 + 2*k2 + 2*k3 + k4))

# Time and parameter(mu)
Label(t, mu) = sprintf("{/Times:Italic t} = %.1f\n{/symbol:Italic m} = %.1f", t, mu)

#=================== Plot ====================
# Initiate value
t  = 0.           # Time
x[1] = 0.5        # x1(t)
y[1] = 0.0        # x1'(t)
x[2] = 1.0        # x2(t)
y[2] = -3.0       # x2'(t)
x[3] = -1.7       # x3(t)
y[3] = 1.9        # x3'(t)
x[4] = 1.0        # x4(t)
y[4] = 2.1        # x4'(t)
x[5] = 3.5        # x5(t)
y[5] = 3.7        # x5'(t)
x[6] = -3.        # x6(t)
y[6] = -3.        # x6'(t)

# Axes
set arrow 1 from -L, 0 to L, 0 lc -1 lw 2 back
set arrow 2 from 0, -L to 0, L lc -1 lw 2 back

# Draw initiate state for lim1 steps
do for [i = 1:lim1] {
    # Display time and mu
    set label 1 left Label(t, mu) font 'Times New Roman, 18' at graph 0.02, 0.95

    # Display coordinates of N points
    if(i < lim1*0.8){
        do for[j = 1:N] {
            set label j+1 left sprintf("(%.1f, %.1f)", x[j], y[j])\
                font 'Times New Roman, 14' at x[j]+off, y[j]+off
        }
    }

    # Hide the coordinates
    if(i == lim1*0.8){
        do for[j = 1:N] {
            unset label j+1
        }
    }

    # N points
    do for[j=1:N] {
        set obj j circ at x[j], y[j] size r fc rgb c[j] fs solid border -1 lw 2 front
    }

    plot 1/0
}

# Update for lim2 steps
do for [i = 1:lim2] {
    t = t + dt

    # Calculate using Runge-Kutta 4th
    do for[j = 1:N]{
        x[j] = x[j] + rk4x(x[j], y[j])
        y[j] = y[j] + rk4y(x[j], y[j])
    }

    # Time and mu
    set label 1 Label(t, mu)

    # Objects
    do for[j = 1:N] {
        set obj j at x[j], y[j]
        set obj 6*i+j circ at x[j], y[j] size 0.09*r fc rgb c[j] fs solid
    }

    # Decimate and display
    if(i%cut==0){
        plot 1/0
    }
}

set out