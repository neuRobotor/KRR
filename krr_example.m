% Process Sample Dataset
% double_perovskites_gap.csv
clear all;clc;

data=zscore(csvread('GaussianData.csv'));
x=data(:,1:end-1);
y=data(:,end);

N = length(y);

%random shuffle
shuffled_indexes = randperm(N);
x = x(shuffled_indexes,:);
y = y(shuffled_indexes,:);


%test/train split
N_test = N-(N*0.9);
N_train = N-N_test;

x_test = x((N*0.9)+1:end,:);
x_train = x(1:(N*0.9),:);

y_test = y((N*0.9)+1:end,:);
y_train = y(1:(N*0.9),:);


%gaussian
K_gauss=zeros(N_train,N_train);
for j=1:N_train
 for i=1:N_train
    K_gauss(i,j)=exp(-norm(x_train(j,:)-x_train(i,:)));
 end
end


y_predicted_sample=zeros(N_train,1);
y_predicted=zeros(N_test,1);

intvl=0.1;

in_sample_error = zeros(1/intvl,1);
out_sample_error = zeros(1/intvl,1);

for lambda=intvl:intvl:1
    fprintf('On iteration: %d of %d\n',int32((lambda/intvl)),(1/intvl));
    for i=1:N_train
        if mod(i,50) == 0
            fprintf('Training on Sample: %d of %d\n',i,N_train);
        end
        y_predicted_sample(i,1)= y_train'*((K_gauss+ lambda*eye(N_train))\K_gauss(i,:)');
    end
    in_sample_error(int32(lambda/intvl)) = norm(y_predicted_sample-y_train)^2/N_train;
    
    for i=1:N_test
        y_predicted(i,1)= y_train'*((K_gauss+ lambda*eye(N_train))\(x_train*(x_test(i,:)')));
    end
    out_sample_error(int32(lambda/intvl)) = norm(y_predicted-y_test)^2/N_test;
end


%in sample
figure
hold on

scatter3(x_train(:,1),x_train(:,2),y_train,'g')
scatter3(x_train(:,1),x_train(:,2),y_predicted_sample,'r')

title('IN SAMPLE')
xlabel({'x_1'})
ylabel({'x_2'})
zlabel('y')
view([-47.1 4.4])

hold off

%out of sample
figure
hold on

scatter3(x_test(:,1),x_test(:,2),y_test,'g')
scatter3(x_test(:,1),x_test(:,2),y_predicted,'r')

title('OUT SAMPLE')
xlabel({'x_1'})
ylabel({'x_2'})
zlabel('y')
view([-47.1 4.4])

hold off