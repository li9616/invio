%computing the state transition jacobian for the loosely coupled visual
%odometry

syms x y z qw qx qy qz lambda b_dx b_dy b_dz b_wx b_wy b_wz b_ax b_ay b_az gx gy gz bias_accel_x bias_accel_y bias_accel_z bias_gyro_x bias_gyro_y bias_gyro_z dt

pos = [x;y;z]
quat = [qw;qx;qy;qz]
vel = [b_dx;b_dy;b_dy]
accel = [b_ax;b_ay;b_az]
omega = [b_wx;b_wy;b_wz]

pos_process = [pos + quaternionRotate(quat, lambda*(dt*vel + 0.5*dt*dt*accel))]

omega_norm = norm(omega);
v = omega/omega_norm;
theta = dt*omega_norm;
dq = [cos(theta/2); v*sin(theta/2)]
dq_inv = [cos(theta/2); -v*sin(theta/2)]

quat_process = multiplyQuaternions(quat, dq)
gravity_vector_process = quaternionRotate(dq_inv, [gx;gy;gz])

vel_process = [vel + dt*accel]

process = [pos_process;
            quat_process;
            lambda;
            vel_process;
            omega;
            accel;
            gravity_vector_process;
            bias_accel_x; bias_accel_y; bias_accel_z; bias_gyro_x; bias_gyro_y; bias_gyro_z]
        
J = jacobian(process, [x y z qw qx qy qz lambda b_dx b_dy b_dz b_wx b_wy b_wz b_ax b_ay b_az gx gy gz bias_accel_x bias_accel_y bias_accel_z bias_gyro_x bias_gyro_y bias_gyro_z])



% compute the case for a zero omega
process_zero = [pos_process;
            quat;
            lambda;
            vel_process;
            omega;
            accel;
            gx;gy;gz;
            bias_accel_x; bias_accel_y; bias_accel_z; bias_gyro_x; bias_gyro_y; bias_gyro_z]
        
J_zero = jacobian(process_zero, [x y z qw qx qy qz lambda b_dx b_dy b_dz b_wx b_wy b_wz b_ax b_ay b_az gx gy gz bias_accel_x bias_accel_y bias_accel_z bias_gyro_x bias_gyro_y bias_gyro_z])


%test expression with zero omega
%double(subs(J_zero, [x y z qw qx qy qz lambda b_dx b_dy b_dz b_wx b_wy b_wz b_ax b_ay b_az gx gy gz bias_accel_x bias_accel_y bias_accel_z bias_gyro_x bias_gyro_y bias_gyro_z], [1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, -9.8, 0, 0, 0, 0, 0, 0]))

ccode(J, 'File', 'lc_process_nonzero.c')
ccode(J_zero, 'File', 'lc_process_zero.c')