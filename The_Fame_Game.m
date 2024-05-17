#April 2021 Aris Anagnostakis
#IoT micro-Blockchain modeling of cluster behavior 
#Code for octave and Matlab after Jan 26 2021 Notes and Scketch Jan_23 https://github.com/arianagnostakis/IoT_Blockchain
#all times as benchmarked in milliseconds
#building the Fame Game relying on the Witness Protocol of the IoT microBlockchain that can be found in the link above.
#Proving that for known N there is a maximum in the total points that can be gathered in the system.  
#Every rational player will eventually find the right combination of w and Tevents (HAT) that maximizes its' points, 
#given that they all share the same strategy. (Pclient/Pserver is common).

clear
labels = {};
#The Fame Fame Game
      PointsTT = -100; # this is the "rude behavior"
      PointsTL = +110; #=LT this is the "polite behavior"
      PointsLL = -10; #-20 this is the "lazyness penalty"
#Benchmarks from the IoT experiment
      TotalMessages=0;
      Tcs = 3713;
      Tsc_Success = 100; #5067;
      Tsc_Failure = 100; #10361;
      Ttransmission = 519;
      Treception = 579;
      Tverify = 3;
      Thash = 4;
      Tsign = 3;
      Tcopy = 9;
      Tidle = 1;
      Taddexternal = 28;
      HAT=140000; #Time interval among Local events on a Node (ms) 100000 (Local events happen once in 100 sec) #Hyperlazy 2000000, #Hyperactive 2000
      Timeframe=HAT;
      Timeservice=Tsc_Success+Treception+Tverify+Tcopy+Thash+Tsign;
      AttemptsInTimeframe=Timeframe/Timeservice; #How many attempts can be serviced until a new local even rises
      N=100; #Total nodes in known neighbourhood
      W=1; #Total number of neighbors I want to try to inform of my event
      H=10; #Total different Tevent rounds 
    Points = zeros (H,N); #initialize the score-board in fame-game points per event
    TotalPoints = zeros (H,N); #points per all anticipated events in a timeframe
    for HATT=1:H
      HAT=HAT+20000;
      Pwitness = zeros (1,N); # Pwitness corresponds to the number of witnesses on a specific Local Event, given W attemts to share it

      for W=1:N
        Tclient=(Tsc_Success+Ttransmission); #*W
       
        Pclient= (W*Tclient)/HAT
 
        Pserver=1-Pclient;
        
        #Estimate witness profability as a function of Timeframe and Nefighboring nodes in network
        #Piwitness= Probability that node j becomes witness of the current event on IoT device i 
        #Pwitness= Probability that there is at least one witness other than me
        Piserveothers=0;
        i=(min(W, AttemptsInTimeframe)); #if everyone contacts W neighbors to share a Local Event to find a witness, what Possibility do i have to get at least one?
        for j=2:i
          Piserveothers=Piserveothers+(Pclient/(N-2));
        endfor

        #Piserveothers=(Pclient*W*(AttemptsInTimeframe-1))/(N-2)W
        Piwitness=Pserver-Piserveothers;
        Pwitness(W)=0;
        Pwitness(W)=i*Piwitness; #the probability of i witnesses existence

        #calculating points per round
        # W rounds are being played by a single player in the light of a Local event
        Points(HATT,W)= W*(((2*(Pclient*Piwitness)*PointsTL))+((Pclient^2)*PointsTT)+((Pserver^2)*PointsLL)); 
        TotalPoints(HATT,W)=N*(W*(((2*(Pclient*Piwitness)*PointsTL))+((Pclient^2)*PointsTT))+((N-W)*((Pserver^2)*PointsLL)));
      endfor
      [x,xi]=max(Pwitness)
      xi/N
      Points(HATT,:);
    #bar (Pwitness)
    #endfor

#plot results
mesh(Points)
    hold on
    xlabel('Number of Witnesses (w)',"fontsize",40)
    ylabel(' Points gathered by each of the N Nodes for each event',"fontsize",40)
    set(gca, "fontsize", 25)
    [wi,wii]=max(Points(HATT,:));
    labels = {labels{:}, ["Te= ", num2str(HAT), " ms, Max points: ", num2str(max(Points(HATT,:))), ", for W=", num2str(wii)]};
    legend (labels, "location", "Southwest","fontsize",30);
  endfor  
hold off
