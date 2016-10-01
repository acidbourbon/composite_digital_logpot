% simulation of a logarithmic volume poti consisting of two cascaded digital potentiometers

clear

% This script needs to be run with GNU Octave
% Last time it ran well with GNU Octave, version 3.8.1

% 2013 by Michael Wiebusch
%
% acidbourbon.wordpress.com
% mwiebusch.de

% adapt the following constants to fit your digital potentiometers

% ##########         properties of linear digipots in use         ##########
R             = 10000; % 10kOhms poti resistance
R_w           = 45;    % "wiper" resistance
poti_steps    = 257;   % how many steps does the digipot have?

% ##########  desired properties of resulting logarithmic digipot ##########
target_steps  = 64;    % how many steps should the resulting potentiometer have?
highest       = 0;     % highest desired volume setting (in dB) = lowest attenuation
lowest        = -64;   % lowest desired volume setting (in dB) = highest attenuation

% ##########          manual fine tuning for "punishment"         ##########
punish_factor = 0.01;  % punishment factor for target point being in a higher error region
punish_exp    = 1;     % punishment exponent



function [i,j,residual]=findclosest_m(matrix,value,punish_matrix)
  residual_matrix = abs(matrix-value)+punish_matrix;
  residual = min(min(residual_matrix));
  [a,b] = find(residual_matrix==residual);
  i=a(1,1);
  j=b(1,1);
end

function o=att_dd(pos1,pos2) % attenuation of double divider
  o= 1/(1-pos1+1/pos1) * pos2;
end

function U_o=att_dd_Rw(pos1,pos2,R,R_w) % attenuation of double divider, take in account wiper resistance
  R_m = 1/(1/(R+R_w)+1/(R*pos1)); % midpoint resistance
  U_m = R_m/(R_m + R*(1-pos1));
  U_o = U_m*1/(1+R_w/R)*pos2;
end

function o=err_att_dd(pos1,pos2)
  % i calculate with the maximum error (not gaussian)
  o=abs(1/(1-pos1+1/pos1)) + abs(pos2 * (1+1/(pos1^2))/((1-pos1+1/pos1)^2) );
end

function O=decibel(ratio) % convert amplitude ratio to dB
O=20*log10(ratio);
end



poti_ratio=linspace(0,1,poti_steps);
poti_ratio(1)=0.001; % avoid division by zero

attenuation=zeros(poti_steps);



for i=1:poti_steps
  for j=1:poti_steps
    
%      attenuation(i,j) = att_dd(poti_ratio(i),poti_ratio(j));
    attenuation(i,j) = att_dd_Rw(poti_ratio(i),poti_ratio(j),R,R_w);
    error(i,j)       = err_att_dd(poti_ratio(i),poti_ratio(j));
    
  end
end


relative_error = error./attenuation;

attenuation_db=arrayfun(@decibel,attenuation);
error_db=arrayfun(@decibel,error);

%  dBmatrix=dBmatrix.*allowed_mask;
%  dBmatrix=dBmatrix +(forbidden_mask*10);

target_vals = linspace(lowest,highest,target_steps);

punish_matrix= punish_factor*abs(relative_error.^punish_exp);


lut_file = fopen('lookup.csv', 'w');

fprintf(lut_file,"#combi_pos\t#pos1\t#pos2\t#attenuation (dB)\n");

%  fprintf(lut_file,"package lookup;\nsub lookup {return $lookup;}\n");
%  fprintf(lut_file,"our $lookup = {\n");

for k=1:target_steps
  target_val=target_vals(k);
  [a,b,match_residual] = findclosest_m(attenuation_db,target_val,punish_matrix);
%    i;
%    a;
%    b;
  match_residual;
  matchi(k)=a;
  matchj(k)=b;
  closest_value(k)=attenuation_db(a,b);
  fprintf(lut_file,"%d\t%d\t%d\t%f\n",k,matchi(k),matchj(k),closest_value(k));
%    fprintf(lut_file,"\t%d => { 1 => %d, 2 => %d, target =>%f },\n",k,matchi(k),matchj(k),closest_value(k));
end
%  fprintf(lut_file,"};\n1;\n");
fclose(lut_file);

figure
hold
imagesc(attenuation_db)
h = colorbar ();
 ytick = get (h, 'ytick');
 set (h, 'yticklabel', sprintf ('%g dB|', ytick));
plot(matchi,matchj)
plot(matchi,matchj,"+")
title("attenuation matrix [dB] and optimal trajectory");
xlabel("wiper pos R1");
ylabel("wiper pos R2");
print -dpng trajectory_and_attenuation.png
hold off

figure
hold
imagesc(relative_error)
h = colorbar ();
 ytick = get (h, 'ytick');
 set (h, 'yticklabel', sprintf ('%g a.u.|', ytick));
plot(matchi,matchj)
plot(matchi,matchj,"+")
title("relative error matrix (arbitrary units) and optimal trajectory");
xlabel("wiper pos R1");
ylabel("wiper pos R2");
print -dpng trajectory_and_error.png
hold off

figure
hold
plot(closest_value,"+");
plot(target_vals);
title("behaviour of combi-pot");
xlabel("combi wiper pos");
ylabel("attenuation [dB]");
print -dpng combi_pot_behaviour.png
hold off

figure
hold
plot(closest_value-target_vals,"+");
title("error (residuals) of combi-pot");
xlabel("combi wiper pos");
ylabel("selected attenuation - ideal attenuation [dB]");
print -dpng residuals.png
hold off



