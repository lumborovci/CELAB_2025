%% Frequency-Shaped LQR (Robust + Integral Case)
% Assign a spectral cost to the frequency at which the Natural Evolution of
% the System might undergo resonance. Function built on a separate script

% Load Motor and SSM Parameters
run("Plant_ModelParameters.m");
run("Controller_LAB3_ssVAR.m");

open("Model_LAB3_ssSYSTEM_robust.slx");

%% State Feedback Design using Matrix-Valued, FS-LQR

q2_vals = [0.01, 1, 100];
qi_vals = [0.01, 0.1, 1, 10, 100];

% Arrays to store e.m. comparison results
real_vals = zeros(size(q2_vals));
imag_vals = zeros(size(q2_vals));
attenuation_vals = zeros(size(q2_vals));

function [Ae, Be, omega_0, K_vals, eig_A] = fs_lqr(q2_value, qi_vals, A_prime, B_prime, C_prime)

    clear K_fb; % make way for feedback to be designed

    % Obtaining the resonant frequency of the Extended Natural System Evolution:
    
    eig_A = eigs(A_prime);
    
    omega_0 = abs(imag(eig_A(find(imag(eig_A) ~= 0, 1))));
    
    % Building the Frequency-Shaped Components (See Assignment Paper)
    
    % Define the frequency-shaping filter / SSM Realization of transfer function H(s):

    Hss.A = [0 1; -omega_0^(2), 0];
    Hss.B = [0;1];
    Hss.C = [sqrt(q2_value)*omega_0^(2), 0];
    Hss.D = 0;

    % SSM Realization of the Filtering Matrix H_Q(s):
    A_q = Hss.A;
    B_q = [zeros(2,1), Hss.B, zeros(2)];
    C_q = [zeros(1,2); Hss.C; zeros(2)];

    D_q_vec = [1/((0.3)*(5)), Hss.D, 0, 0];
    D_q = diag(D_q_vec);

    % Augment A_prime and B_prime
    A_aug = [A_prime, zeros(4,2) ; B_q, A_q];
    B_aug = [B_prime; 0;0];
    C_aug = [C_prime, zeros(1,2)];
    D_aug = 0;

    Q_aug = [D_q'*D_q, D_q'*C_q; C_q'*D_q, C_q'*C_q];

    % Extended Matrices to include Integral Action
    
    Ae = [0, C_aug; zeros(6,1), A_aug];
    Be = [0; B_aug];
    Ce = [0, C_aug];
    
    fprintf("Checking system matrices before LQR...\n");
    fprintf("Controllability rank: %d (expected: %d)\n", rank(ctrb(Ae, Be)), size(Ae,1));


    % Defining Cost Matrices:

    R_aug = 1 / (10^2);  % Still bound input by 10V

    Re = R_aug;
    

    K_vals = [];

    for i = 1:length(qi_vals)
    
        % Define Qe fresh every time
        Qe = blkdiag(qi_vals(i), Q_aug);  % 1 + 6 = 7 state cost
    
        % Check definiteness
        fprintf("Min eigenvalue of Qe (%d): %.4e\n", i, min(eig(Qe)));
        fprintf("Min eigenvalue of Re: %.4e\n", min(eig(Re)));
    
        % Compute LQR gain
        K_fb = lqr(Ae, Be, Qe, Re);  % Expect 1×7
    
        % Store gain
        K_vals = [K_vals; K_fb];

    end
    
    % push into workspace (for the H_Q(s) SSM Block):
    assignin('base', 'A_q', A_q);
    assignin('base', 'B_q', B_q);

    % Solving for the Nominal Feedforward Gains:

    M = [A_aug, B_aug; C_aug, D_aug];

    Sol = M \ [0;0;0;0;0;0;1];

    Nx = Sol(1:6, :);
    Nu = Sol(7,:);

    assignin('base', 'Nx', Nx);
    assignin('base', 'Nu', Nu);
    
end

%% Running the Simulation:

model_name = 'Model_LAB3_ssSYSTEM_robust';
load_system(model_name);

% Step amplitude and simulation time
A_set = 50;  % deg
sim_time = 10;

% Results containers
results_fs = table();
eig_shift_results = table();

% Sweep over q2 values
for i = 1:length(q2_vals)

    q2 = q2_vals(i);

    % Design 5 FS-LQR controllers for this q2 (with 5 qi options)
    [Ae, Be, omega_0, K_vals, eig_A] = fs_lqr(q2, qi_vals, A_prime, B_prime, C_prime);

    for j = 1:length(qi_vals)

   
        % Assign current controller to base
        assignin('base', 'K_fb', K_vals(j,:));

        % Simulate the system
        set_param([model_name '/Position Reference [deg]'], 'After', num2str(A_set));
        
        pause(0.1);
        
        set_param(model_name, 'SimulationCommand', 'update');
        simOut = sim(model_name, 'StopTime', num2str(sim_time), ...
                                'ReturnWorkspaceOutputs', 'on');

        pos = simOut.get('pos_meas_hub');
        t = pos.Time;
        y = pos.Data;

        % Step metrics
        S = stepinfo(y, t, 'RiseTimeLimits', [0.1 0.9], ...
                           'SettlingTimeThreshold', 0.05);

        % Store in results table
        results_fs = [results_fs;
            table(q2, qi_vals(j), A_set, S.RiseTime, S.SettlingTime, S.Overshoot, ...
                  'VariableNames', {'q2_Value', 'qi_Value', 'RefAmplitude_deg', ...
                                    'RiseTime', 'SettlingTime', 'Overshoot'})];

        % Eigenvalue tracking (resonant mode)
        eig_cl = eig(Ae - (Be * K_vals(j,:))); 

        [~, idx_res] = min(abs(imag(eig_cl) - omega_0));
        lambda_res = eig_cl(idx_res);

        [~, idx_open] = min(abs(imag(eig_A) - omega_0));
        lambda_res_open = eig_A(idx_open);

        % Store in eigenvalue results table
        eig_shift_results = [eig_shift_results;
            table(q2, qi_vals(j), real(lambda_res), real(lambda_res_open), ...
                  real(lambda_res) - real(lambda_res_open), imag(lambda_res), ...
                  'VariableNames', {'q2_Value', 'qi_Value', ...
                                    'ClosedLoop_Resonant_Eig_RealPart', ...
                                    'OpenLoop_Resonant_Eig_RealPart', ...
                                    'Real_Shift', 'Resonant_Eig_ImagPart'})];
    end
end

% Save tables
writetable(results_fs, 'LAB3_FS_LQR_step_results.csv');
writetable(eig_shift_results, 'LAB3_FS_LQR_eigenvalue_shifts.csv');
fprintf('✅ Saved all FS-LQR step and eigenvalue results.\n');


%% Plotting eigenvalue shifts

% Unique q2 values
q2_vals = unique(eig_shift_results.q2_Value);

colors = {'r', 'g', 'b'};  % red, green, blue

for i = 1:length(q2_vals)
    q2 = q2_vals(i);

    % Filter table for current q2 value
    T_q2 = eig_shift_results(eig_shift_results.q2_Value == q2, :);

    % Extract data
    x = 1:height(T_q2);
    real_vals        = T_q2.ClosedLoop_Resonant_Eig_RealPart;
    imag_vals        = T_q2.Resonant_Eig_ImagPart;
    attenuation_vals = T_q2.Real_Shift;
    x_labels = "q_i = " + string(T_q2.qi_Value);

    % --- Create Figure for This q2 ---
    figure('Name', sprintf('Resonant Mode Shift for q2 = %.2f', q2), ...
           'Position', [100 100 1000 800]);

    % Format line style with color
    style_1 = sprintf('%s-o', colors{i});
    style_2 = sprintf('%s-s', colors{i});
    style_3 = sprintf('%s-x', colors{i});

    % --- Real Part ---
    subplot(3,1,1); hold on; grid on;
    plot(x, real_vals, style_1,'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    text(x, real_vals, compose('%.2f', real_vals), ...
         'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',9);
    ylabel('Real Part of Pole');
    title(sprintf('{Re} Resonant Mode (q_{22} = %.2f)', q2));
    set(gca, 'XTick', x, 'XTickLabel', x_labels); xtickangle(0);

    % --- Imaginary Part ---
    subplot(3,1,2); hold on; grid on;
    plot(x, imag_vals, style_2,'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    text(x, imag_vals, compose('%.2f', imag_vals), ...
         'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',9);
    ylabel('Imaginary Part');
    title(sprintf('{Im} Resonant Mode (q_{22} = %.2f)', q2));
    set(gca, 'XTick', x, 'XTickLabel', x_labels); xtickangle(0);

    % --- Attenuation Shift ---
    subplot(3,1,3); hold on; grid on;
    h = plot(x, attenuation_vals, style_3, 'MarkerEdgeColor','k', 'LineWidth', 1.5);
    text(x, attenuation_vals, compose('%.2f', attenuation_vals), ...
         'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',9);
    ylabel('Real Axis Shift'); xlabel('q_i Value');
    title(sprintf('Resonant Mode Shift due to FS-LQR (q_{22} = %.2f)', q2));
    
    % Create dummy invisible plots for legend
    h_legend1 = plot(nan, nan, 'k-x', 'DisplayName', 'Shift < 0 → Damped Resonant Mode');
    h_legend2 = plot(nan, nan, 'k-x', 'MarkerFaceColor', 'k', ...
                              'DisplayName', 'Shift > 0 → Amplified Resonant Mode');
    
    % Add legend with correct symbols and formatting
    legend([h_legend1 h_legend2], ...
           'Location', 'northeast', ...
           'Interpreter', 'none');
    
    set(gca, 'XTick', x, 'XTickLabel', x_labels); xtickangle(0);

    % Save figure and table
    fig_filename = sprintf('LAB3_FS_LQR_resonant_shift_q2_%.2f.png', q2);
    csv_filename = sprintf('LAB3_FS_LQR_eig_shift_q2_%.2f.csv', q2);

    saveas(gcf, fig_filename);
    writetable(T_q2, csv_filename);

    fprintf("✅ Saved plot: %s\n", fig_filename);
    fprintf("✅ Saved table: %s\n", csv_filename);
end

%% Plotting Step Response for FS-LQR (Robust + Integral)

figure('Name', 'FS-LQR Step Response vs q_i for each q_2', 'Position', [100 100 1000 800]);

% Prepare x-axis for qi
x = 1:length(qi_vals);
x_labels = "q_i = " + string(qi_vals);

% Styles for each q2 value
styles = {'r-o', 'g-s', 'b-d'};
q2_labels = "q_{22} = " + string(q2_vals);

% Check that styles array is long enough
assert(length(styles) >= length(q2_vals), 'Not enough line styles defined for q2 values');

% --------- Rise Time ---------
subplot(3,1,1); hold on; grid on;
for i = 1:length(q2_vals)
    idx = results_fs.q2_Value == q2_vals(i);
    xi = find(idx);
    yi = results_fs.RiseTime(xi);
    plot(x, yi, styles{i}, 'LineWidth', 1.25, 'DisplayName', q2_labels(i));
    text(x, yi + 0.01, compose('%.2f', yi), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 9);
end
set(gca, 'XTick', x, 'XTickLabel', x_labels);
ylabel('Rise Time (s)');
title('Rise Time vs q_i');

% --------- Settling Time ---------
subplot(3,1,2); hold on; grid on;
for i = 1:length(q2_vals)
    idx = results_fs.q2_Value == q2_vals(i);
    xi = find(idx);
    yi = results_fs.SettlingTime(xi);
    plot(x, yi, styles{i}, 'LineWidth', 1.25, 'DisplayName', q2_labels(i));
    text(x, yi + 0.01, compose('%.2f', yi), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 9);
end
set(gca, 'XTick', x, 'XTickLabel', x_labels);
ylabel('Settling Time (s)');
title('Settling Time vs q_i');

% --------- Overshoot ---------
subplot(3,1,3); hold on; grid on;
for i = 1:length(q2_vals)
    idx = results_fs.q2_Value == q2_vals(i);
    xi = find(idx);
    yi = results_fs.Overshoot(xi);
    plot(x, yi, styles{i}, 'LineWidth', 1.25, 'DisplayName', q2_labels(i));
    text(x, yi + 0.3, compose('%.1f', yi), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 9);
end
set(gca, 'XTick', x, 'XTickLabel', x_labels);
ylabel('Overshoot (%)');
xlabel('Integrator Cost (q_i)');
title('Overshoot vs q_i');
legend('show', 'Location', 'northwest');

% Save plot
filename_plot = 'LAB3_fslqr_step_response_vs_qi.png';
saveas(gcf, filename_plot);
fprintf("✅ Saved FS-LQR step response plot to: %s\n", filename_plot);

close_system("Model_LAB3_ssSYSTEM_robust.slx",0);
