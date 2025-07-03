% Bayesian optimization of K, dt parameters in Kuramoto model via Matlab
for N = 4:8
    fprintf('Optimizing for N = %d\n', N);
    
    % Define the objective function for the Kuramoto model
    objectiveFunction = @(params) kuramotoObjective(params.K, params.dt, N);
    
    % Set the variables to be optimized
    K = optimizableVariable('K', [0.005, 0.975], 'Type', 'real');
    dtdt = optimizableVariable('dt', [0.01, 0.75], 'Transform', 'log');
    vars = [K, dtdt];
    
    % Perform Bayesian optimization
    results = bayesopt(objectiveFunction, vars, ...
        'AcquisitionFunctionName', 'expected-improvement-plus', ...
        'IsObjectiveDeterministic', false, ...
        'MaxObjectiveEvaluations', 250, ...
        'Verbose', 1);
    
    % Display results for this N
    fprintf('Best parameters for N=%d: K=%.4f, dt=%.4f\n', ...
        N, results.XAtMinObjective.K, results.XAtMinObjective.dt);
end