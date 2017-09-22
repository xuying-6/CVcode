function hog_arr = sp_find_hog_grid(I, cell_size)

%٤��У��
I = sqrt(I);     

%���������Ե
fx = [-1 0 1];        % ����ˮƽģ��
fy = -fx';            % ������ֱģ��
Ix = imfilter(I,fx,'replicate');    % ˮƽ��Ե
Iy = imfilter(I,fy,'replicate');    % ��ֱ��Ե
I_mag = sqrt(Ix.^2+Iy.^2);          % ��Եǿ�ȣ�Ȩֵ
I_theta = Iy./Ix;            % ��Եб�ʣ���ЩΪinf,-inf,nan������nan��Ҫ�ٴ���һ��

I_theta(find(isnan(I_theta))) = 0; % ��0����Ƿ��Ľ������Ϊ��Щ�ط����ݶ�ֵΪinf


%��������cell
[hgt, wid] = size(I);     % �ж�Ӧ�ߣ��ж�Ӧ��
step = cell_size;         % ����
orient = 9;               % ����ֱ��ͼ�ķ������
jiao = 360/orient;        % ÿ����������ĽǶ���
Cell = cell(1,1);         % ���еĽǶ�ֱ��ͼ,cell�ǿ��Զ�̬���ӵģ�������������һ��                     

jj = 1;
for i = 1:step:hgt-mod(hgt,step)          % ���������hgt/step����������������Ҳ���ԣ���Ϊmod����Ϊ0
    ii = 1;
    for j = 1:step:wid-mod(wid,step)       % ע��ͬ��
        tmpx = Ix(i:i+step-1,j:j+step-1);  % ȡһ��Ԫ���ݶ�Gx
        tmped = I_mag(i:i+step-1,j:j+step-1);  % ȡһ��Ԫ���ݶ�ֵ
        tmped = tmped / sum(sum(tmped));        % �ֲ���Եǿ�ȹ�һ��������ȨȨֵ
        tmp_theta = I_theta(i:i+step-1,j:j+step-1); % ȡһ��Ԫ�����ݶȷ���
        Hist = zeros(1,orient);         % ��ǰstep*step���ؿ�ͳ�ƽǶ�ֱ��ͼ,����cell
        for p = 1:step
            for q = 1:step
                ang = atan(tmp_theta(p,q));    % atan�����[-90 90]��֮��
                ang = mod(ang*180/pi,360);    % ȫ��������-90��270
                if tmpx(p,q) < 0              % ����x����ȷ�������ĽǶ�
                    if ang < 90               % ����ǵ�һ����
                        ang = ang+180;        % �Ƶ���������
                    end
                    if ang > 270              %����ǵ�������
                        ang = ang-180;        %�Ƶ��ڶ�����
                    end
                end
                ang = ang + 0.0000001;          %��ֹangΪ0
                Hist(ceil(ang/jiao)) = Hist(ceil(ang/jiao)) + tmped(p,q);   %ceil����ȡ����ʹ�ñ�Եǿ�ȼ�Ȩ
            end
        end
        % Hist = Hist/sum(Hist);   % ����ֱ��ͼ��һ������һ������û�У���Ϊ�����block�Ժ��ٽ��й�һ���Ϳ���
        Cell{ii,jj} = Hist;       % ����Cell��
        ii = ii + 1;                % ���Cell��y����ѭ������
    end
    jj = jj + 1;                    % ���Cell��x����ѭ������
end

% ��������feature, 2*2��cell�ϳ�һ��block,û����ʽ����block
[m, n] = size(Cell);
feature = cell(1,(m-1)*(n-1)); % ����Ϊstep���ʻ���m-1����n-1����
for i = 1:m-1
   for j = 1:n-1           
        f = [ Cell{i,j}(:)', Cell{i,j+1}(:)', Cell{i+1,j}(:)', Cell{i+1,j+1}(:)'];  % 4*9=36ά
        f = f./sum(f); % ��һ��
        feature{(i-1)*(n-1)+j} = f;
   end
end

len = length(feature);
hog_arr = [];
for i = 1:len
    hog_arr = [hog_arr;feature{i}(:)'];   % hog_arr��Ϊ����hog����
end