%******************************************************************************************
% Magnetometer Calibration Script, adapted from
% Razor AHRS v1.4.2, available here:
% https://github.com/KristofRobot/razor_imu_9dof/blob/indigo-devel/magnetometer_calibration/Matlab/magnetometer_calibration/magnetometer_calibration.m
%******************************************************************************************

%% Todo manually for now: 
%                           1. convert rosbag in csv and load it in Matlab
%                           using GIU
%                           2. run this script


% do ellipsoid fitting
[e_center, e_radii, e_eigenvecs, e_algebraic] = ellipsoid_fit([x, y, z]);

% compensate distorted magnetometer data
% e_eigenvecs is an orthogonal matrix, so ' can be used instead of inv()
S = [x - e_center(1), y - e_center(2), z - e_center(3)]'; % translate and make array
scale = inv([e_radii(1) 0 0; 0 e_radii(2) 0; 0 0 e_radii(3)]) * min(e_radii); % scaling matrix
map = e_eigenvecs'; % transformation matrix to map ellipsoid axes to coordinate system axes
invmap = e_eigenvecs; % inverse of above
comp = invmap * scale * map;
S = comp * S; % do compensation

% output info
fprintf('In the mbzirc_utils/?? of the MAV, add the following yaml parameters "\n');
fprintf('Replace the existing 3 lines with these:\n\n');
fprintf('magnetometer/offset: [%.6g, %.6g, %.6g]\n', e_center);
fprintf('magnetometer/compensation: [%.6g, %.6g, %.6g, %.6g, %.6g, %.6g, %.6g, %.6g, %.6g]\n', comp);

%% Plot results
% draw ellipsoid fit
figure;
hold on;
plot3(x, y, z, '.r'); % original data

maxd = max(e_radii);
step = maxd / 50;
[xp, yp, zp] = meshgrid(-maxd:step:maxd + e_center(1), -maxd:step:maxd + e_center(2), -maxd:step:maxd + e_center(3));

Ellipsoid = e_algebraic(1) *xp.*xp +   e_algebraic(2) * yp.*yp + e_algebraic(3)   * zp.*zp + ...
          2*e_algebraic(4) *xp.*yp + 2*e_algebraic(5) * xp.*zp + 2*e_algebraic(6) * yp.*zp + ...
          2*e_algebraic(7) *xp     + 2*e_algebraic(8) * yp     + 2*e_algebraic(9) * zp;
p = patch(isosurface(xp, yp, zp, Ellipsoid, 1));
set(p, 'FaceColor', 'g', 'EdgeColor', 'none');

alpha(0.5);
view(-70, 40);
axis vis3d;
axis equal;
camlight;
lighting phong;
title('Original & Fitted Ellipsoid');

% draw original and compensated data
figure;
hold on;
plot3( x, y, z, '.r' ); % original magnetometer data
plot3(S(1,:), S(2,:), S(3,:), 'b.'); % compensated data
view( -70, 40 );
axis vis3d;
axis equal;
legend('original', 'compensated');
title('Calibration Results');