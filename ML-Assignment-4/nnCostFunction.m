function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%

X = [ones(m,1) X];
z1 = sigmoid(Theta1 * X');
a2 = [ones(1, size(z1, 2)); z1];
a3 = sigmoid(Theta2 * a2);
h = a3;

yMatrix = zeros(num_labels, m);

for i=1:num_labels,
    yMatrix(i,:) = (y==i);
endfor

J = (sum( sum( -1*yMatrix.*log(h) - (1 - yMatrix).*log(1-h) ) ))/m;

Theta1Reg = Theta1(:,2:size(Theta1,2));
Theta2Reg = Theta2(:,2:size(Theta2,2));

Reg = (lambda/(2*m)) * (sum(sum( Theta1Reg.^2 )) + sum( sum( Theta2Reg.^2 ) ));
J = J + Reg;

for k = 1:m,
    % First, we do forward propogation on an X that already contains
    % the bias node (from above)

    a1 = X(k,:);
    z2 = Theta1 * a1';

    a2 = sigmoid(z2);
    a2 = [1 ; a2];

    % Now we have our final activation layer a3 == h(theta)
    a3 = sigmoid(Theta2 * a2);

    % Now that we have our activation layer, we go backwards
    % This basically just involves following along the formulas given
    % on Page 9
    d3 = a3 - yMatrix(:,k);
    
    % Re-add a bais node for z2
    z2 = [1 ; z2];
    d2 = (Theta2' * d3) .* sigmoidGradient(z2);
    % Strip out bais node from resulting d2
    d2 = d2(2:end);

    Theta2_grad = (Theta2_grad + d3 * a2');
    Theta1_grad = (Theta1_grad + d2 * a1);

endfor;




% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% Implement for Theta1 and Theta2 when l = 0
Theta1_grad(:,1) = Theta1_grad(:,1)./m;
Theta2_grad(:,1) = Theta2_grad(:,1)./m;

% Implement for Theta1 and Theta 2 when l > 0
Theta1_grad(:,2:end) = Theta1_grad(:,2:end)./m + ( (lambda/m) * Theta1(:,2:end) );
Theta2_grad(:,2:end) = Theta2_grad(:,2:end)./m + ( (lambda/m) * Theta2(:,2:end) );

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
