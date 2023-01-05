function xnew = newtonMethod(f1,f2,J,x0,tol,maxiter)
% function to solve a system of two equations in two 
% variables, using newton method
% f1 and f2 are the two functions which represent our equations
% J is the Jacobian of the system
% x0 is a set of initial guesses (in a column vector)
% tol is a tolerance
xold=x0;
fold =  [f1(x0(1), x0(2)); f2(x0(1), x0(2))];
xnew = x0-J(x0(1),x0(2))\fold;

i = 0;
while norm(xnew-xold) > tol && i < maxiter
    xold = xnew;
    fold = [f1(xold(1), xold(2)); f2(xold(1), xold(2))];
    xnew = xold - J(xold(1), xold(2))\fold;
    i = i+1;
    %fprintf("(%d,%d) (%d,%d) %d\n", xnew(1), xnew(2), xold(1), xold(2), norm(xnew - xold));
end
%fprintf("converged in %d steps\n", i);
end