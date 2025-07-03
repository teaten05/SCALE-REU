%The purpose of this script is to simulate the convergance and 
% synchronization of drones in a swarm for ring and all-to-all networks.
% kuramoto_simulation.m
clear; clc;

%% Simulation settings
N_vals = 4:8;                      % Number of drones: 4, 5, 6, 7, 8
K_vals = 0.2:0.1:0.5;              % Coupling strengths: 0.2, 0.3, 0.4, 0.5
topology = 'ring';                 % 'ring' or 'all2all'
Tmax = 35;                         % Simulation time (doesn't matter)
dt = 0.05;
time = 0:dt:Tmax;

% Folder to save all 20 plots.
output_folder = sprintf('results_%s', topology);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Initialize result storage
results = struct();

%% Iterate through all combinations to avoid running program 20 serparate times.
for ni = 1:length(N_vals)
    for ki = 1:length(K_vals)

        %% Parameters for this run
        N = N_vals(ni);
        K = K_vals(ki);
        omega = 1.0 + 0.1 * randn(N, 1);            % Natural frequencies
        theta0 = 2 * pi * rand(N, 1);               % Initial phases

        %% Build adjacency matrix
        A = zeros(N, N);
        switch topology
            case 'all2all'
                A = ones(N) - eye(N);
            case 'ring'
                for i = 1:N
                    A(i, mod(i, N) + 1) = 1;             % Right neighbor
                    A(i, mod(i - 2, N) + 1) = 1;         % Left neighbor
                end
            otherwise
                error('Unknown topology selected.');     % Catching errors
        end

        %% Define ODE function
        kuramoto_rhs = @(t, theta) omega + (K / N) * sum(A .* sin(theta' - theta), 2);

        %% Solve Kuramoto model
        [t_out, theta_out] = ode45(kuramoto_rhs, time, theta0);

        %% Compute order parameter r(t)
        r = zeros(length(t_out), 1);
        for i = 1:length(t_out)
            phases = theta_out(i, :).';
            r(i) = abs(mean(exp(1i * phases)));
        end

        %% Plot phase evolution and r(t)
        figure('Visible', 'off');
        subplot(2,1,1);
        plot(t_out, theta_out);
        title(sprintf('\\theta_i vs. time | N=%d, K=%.1f, Topology=%s', N, K, topology));
        xlabel('Time (s)');
        ylabel('\theta_i(t)');
        legend("Drone " + string(1:N), 'Location', 'eastoutside');

        subplot(2,1,2);
        plot(t_out, r, 'k', 'LineWidth', 2);
        title('Order Parameter r(t)');
        xlabel('Time (s)');
        ylabel('r(t)');
        ylim([0 1]);

        %% Save figure
        filename = sprintf('N%d_K%.1f_%s.png', N, K, topology);
        saveas(gcf, fullfile(output_folder, filename));

        %% Store summary in results
        results(ni, ki).N = N;
        results(ni, ki).K = K;
        results(ni, ki).r_curve = r;
        results(ni, ki).t = t_out;
        results(ni, ki).r_final = r(end);
        r90_idx = find(r > 0.9, 1);   % Time to reach r > 0.9
        if ~isempty(r90_idx)
            results(ni, ki).t_converge = t_out(r90_idx);
        else
            results(ni, ki).t_converge = NaN;
        end
    end
end

fprintf('Simulations complete. Results saved in folder: %s\n', output_folder);