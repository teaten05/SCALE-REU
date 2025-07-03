function kuramoto_simulation(K, dt, N, topology)
% Simulates and plots Kuramoto synchronization for given parameters
%The purpose of this script is to simulate the convergance and 
% synchronization of drones in a swarm for ring and all-to-all networks.
% kuramoto_simulation.m


% Simulates and plots Kuramoto synchronization for given parameters

%% Parameters
    %N = 8;                      % Number of drones
    %K = 0.9730;                    % Coupling strength (adjustable)
    Tmax = 20;                  % Simulation time
    %dt = 0.7337;                  % Time step (for plotting)
    time = 0:dt:Tmax;

% Natural frequencies (rad/s)
    omega = normrnd(1.0, 0.1, [N, 1]);

% Initial phases (rad)
    theta0 = 2 * pi * rand(N, 1);

% Choose topology: 'ring' or 'all2all'
    %topology = 'ring';

% Adjacency matrix
    A = zeros(N, N);
    switch topology
        case 'all2all'
           A = ones(N) - eye(N);
        case 'ring'
          for i = 1:N
              A(i, mod(i, N) + 1) = 1;       % Right neighbor
              A(i, mod(i - 2, N) + 1) = 1;   % Left neighbor
         end
    end

%% Kuramoto ODE
    kuramoto_rhs = @(t, theta) omega + (K / N) * sum(A .* sin(theta' - theta), 2);

% Solve ODE
    [t_out, theta_out] = ode45(kuramoto_rhs, time, theta0);

%% Order parameter r(t)
    r = zeros(length(t_out), 1);
    for i = 1:length(t_out)
        phases = theta_out(i, :).';
        r(i) = abs(mean(exp(1i * phases)));
    end

%% Plot results
    figure;
    subplot(2,1,1);
    plot(t_out, theta_out);
    title(['Phase evolution (Topology: ' topology ', K = ' num2str(K) ')']);
    xlabel('Time (s)');
    ylabel('\theta_i(t)');
    legend("Drone " + string(1:N));

    subplot(2,1,2);
    plot(t_out, r, 'k', 'LineWidth', 2);
    title('Order parameter r(t)');
    xlabel('Time (s)');
    ylabel('r(t)');
    ylim([0 1]);

    % Save plot
    filename = sprintf('K%.4f_dt%.4f_N%d_%s.png', K, dt, N, topology);
    saveas(gcf, filename);
end
