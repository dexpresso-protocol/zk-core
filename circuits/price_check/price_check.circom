pragma circom 2.0.0;

/*This circuit template checks that c is the multiplication of a and b.*/  

template PriceCheck () {  

   // Declaration of signals.  
   signal input makerTotalSellAmount;  
   signal input makerRatioBuyArg;  
   signal input makerRatioSellArg;  
   signal input takerTotalSellAmount;
   signal input takerRatioSellArg;
   signal input takerRatioBuyArg; 
   signal isPriceFair;
   signal isPriceRelative;
   signal temp1;
   signal temp2;
   signal temp3;
   signal temp4;
   signal output result;  

   // Price fairness
   temp1 <== makerTotalSellAmount * makerRatioBuyArg;
   temp2 <== makerRatioSellArg * takerTotalSellAmount;
   isPriceFair <-- temp1==temp2 ? 1 : 0; 
   // Contraint
   isPriceFair * (isPriceFair - 1) === 0;

   // Price relativity
   temp3 <== makerRatioSellArg  * takerRatioSellArg;
   temp4 <== makerRatioBuyArg  * takerRatioBuyArg;
   isPriceRelative <-- temp3>=temp4 ? 1 : 0;
   // Contraint
   isPriceFair * (isPriceFair - 1) === 0;

   // Constraints.  
   result <-- isPriceFair & isPriceRelative;
     
}

component main = PriceCheck();
