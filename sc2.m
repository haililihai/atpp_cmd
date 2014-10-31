function [index C sumd D]=sc2(cluster_num,c_c_matrix)
%  c_c_matrix = matrix.c_c_matrix_threshold;
%         jjw = find(c_c_matrix <=0);
%         c_c_matrix(jjw) = 0.001;
%     
%         cluster_number = clusters(sh);
%         filename1 = num2str(cluster_number);
%         filename = strcat('P_',SeedROI_name(2:(end-4)),filename1);
    jjw = find(c_c_matrix <=0);
        c_c_matrix(jjw) = 0.001;
    cluster_number = cluster_num;      
        %Æ×ŸÛÀà
        W = c_c_matrix;
        D = diag(sum(W));
        L = D - W;
        n = length(L);
        L_sym=zeros(n,n);
        for i=1:n
            for j=1:n
                L_sym(i,j) = L(i,j)./(sqrt(D(i,i))*sqrt(D(j,j)));
            end
        end
        [vector d] = eig(L_sym);
        %œ«ÌØÕ÷Öµž³žø±äÁ¿sort_d£»
        sort_d = zeros(1,1);
        for i = 1:length(d)
            sort_d(i) = d(i,i);
        end
        %ÖØÅÅÌØÕ÷Öµ±äÁ¿.
        sort_d = sort(sort_d);
        %ŒÆËãÌØÕ÷ÖµÎª0µÄžöÊý
        count = 0;
        for i = 1:length(sort_d);
            if sort_d(i) <= 0
               count = count + 1;
            end
        end
        %ÇóËùÐèÒªµÄÌØÕ÷ÏòÁ¿.
        wjj_sh = length(sort_d);
        Spe_cluster = zeros(length(vector),cluster_number);
        for i = 1:cluster_number
            for j = 1:length(d)
                if d(j,j) == sort_d(count+i)
                   Spe_cluster(:,i) = vector(:,j);
                end
            end
        end
        b = Spe_cluster;
        [m n] = size(b);
        for i = 1:m
            for j = 1:n
                b(i,j) = b(i,j) * b(i,j);
            end
        end
        b = b';
        normalize_vector = sum(b);
        for k = 1:length(normalize_vector)
            if normalize_vector(k) ==0
               normalize_c_c_matrxi(k,:) = Spe_cluster(k,:);
            else
            Spe_cluster(k,:) = Spe_cluster(k,:) / sqrt(normalize_vector(k));
            end
        end
    
        %ŸÛÀà
        %index = kmeans(Spe_cluster,cluster_number);
        [index C sumd D] = kmeans (Spe_cluster,cluster_number,'Replicates',300 );
end