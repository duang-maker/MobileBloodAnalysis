 function Mass_Density = MassDensity(I_t,I_0, Extinction, Molar)
    % dry_mass(LC) = (1/E)ln(I_0/I_t)
    Absorb = I_0./im2double(I_t);
    Dry_Mass = (1/(Extinction)).*log10(Absorb);
    Mass_Density = Dry_Mass.* Molar.*10; 
end