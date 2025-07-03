function objective = kuramotoObjective(K, dt, N)
    % Kuramoto model function to simulate synchronization of N bodies
    % Returns negative mean synchronization parameter as objective
    % Optional: additional bad weather results (with necessarily 
    %                                           synchronized drone
    %                                           frequencies)
    
    % Random natural frequencies (use consistent seed for reproducibility)
    rng(42); % Optional: for reproducible results
    omega = rand(N, 1) * 2 * pi;
    
    % Time parameters
    T = 50; % Reduced simulation time for faster optimization
    time = 0:dt:T;
    
    % Initial phase angles
    theta = rand(N, 1) * 2 * pi;
    
    % Storage for synchronization parameter
    R_values = zeros(length(time), 1);
    
    % Main simulation loop (no plotting during optimization)
    for i = 1:length(time)
        % Update phase angles using Kuramoto model
        theta_dot = omega + (K/N) .* sum(sin(theta - theta'), 2);
        theta = theta + theta_dot .* dt;
        
        % Calculate the synchronization order parameter
        R_values(i) = abs(sum(exp(1i * theta)) / N);
    end
    
    % Return negative mean synchronization (we want to maximize R)
    % Use mean of last half of simulation to avoid transient effects
    steady_state_start = round(length(R_values) / 2);
    objective = -mean(R_values(steady_state_start:end));
end