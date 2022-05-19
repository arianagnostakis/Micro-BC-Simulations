#By Aris Anagnostakis, Sep. 2021
#Continus authentication model based on
#IoT Blockchain modeling of cluster behavior 
#Set to fascilitate PoO/PoF, PoC/PoI over the IoT Mirco-Blockchain framework
#after Jan 26 2021 Notes and Scketch Jan_23
#
#all times as benchmarked in milliseconds
#
#The existence of multicast broadband connection is considered
clear
labels = {};
      
      #The reference setup: Arduino Nano 33 48MHz reaching 2.46 CoreMark®/MHz
      #Considering single-thread execution we get a total of 2.46 * 48 overall CPU capacity(=c).
      #1 ms execution time delivers c*10^-3 Coremark equivalent power in the ref. CPU
      #Thus the capacity is calculated by the formula:
      RefMHz=48; # arduino nano 33 IoT
      MHz=96 #NUCLEO 72; #ArmCortex 96; #Arduino 48
      RefCoreMark=2.46; #arduino nanno 33 IoT
      CoreMark=2.843; #Arduino 2.46; #NUCLEO 1.5; 
      RefCPUcapacity=RefCoreMark*RefMHz; 
      CPUcapacity=CoreMark*MHz;
      RefCPUloadms=RefCPUcapacity*(10^-3); #=0.1181 for Arduino Nano 33 #this is the per milisecond accumulative CPU effort in CoreMark Equivalent
      CPUloadms=CPUcapacity*(10^-3);
         
      
      #The size of the Block in Bytes in Jan_20b' .ino
      Blocksize=248*8; #The primary IoT package in bits
      BandwidthAvg=54*2^20/2^3;#Bits per millisecond. Theoretical maximum in wifi:72*2^20 bps
      ConnectionEstablishmentTime=23; #millis of handshake
      
      #Benchmarks derived from the actual Arduino setup /scketch 20 .ino file
      Tcs = 3713; #Time in millis to swap modes. Necessary in every Peer connection. Foreseen amedment: Two threads, listening and transmitting simultaneuslly in every node.
      Tsc_Success = 0.05; #100; #5067; time in millis; in case of Constant multicast channel, minimal 1 msec connection time is estimated/considered corresponds to successfull handshake time
      Tsc_Failure = 1; #100; #10361;
      Ttransmission = Blocksize/BandwidthAvg; #519; #In millis. Peer IoT Benchmarked pure P2P 519 millis with 1 ms/byte interval #Block transmission time on success
      Treception = Blocksize/BandwidthAvg;#579; #Block reception time on success
      #Tverify = 3; #Block verification time in millis 
      TverifyLoad=3*RefCPUloadms;
      Tverify = TverifyLoad/CPUloadms;
      #Thash = 4; #SHA256 for the Block
      ThashLoad=4*RefCPUloadms;
      Thash = ThashLoad/CPUloadms;
      #Tsign = 3; 
      TsignLoad=3*RefCPUloadms;
      Tsign=TsignLoad/CPUloadms;
      #Tcopy = 9;
      TcopyLoad=9*RefCPUloadms;
      Tcopy=TcopyLoad/CPUloadms;
      Tidle = 1;
      #Taddexternal = 28;
      TaddexternalLoad=28*RefCPUloadms;
      Taddexternal=TaddexternalLoad/CPUloadms;
          
      
      HAT= 5.00 #minimum local events frequency supported by the realm to achieve maximum (W=N-1) witnesses. #Time interval in millis among Local events on a Node (ms)

      Timeframe=HAT;
      Timeservice=Tsc_Success+Treception+Tverify+Tcopy+Thash+Tsign;
      AttemptsInTimeframe=Timeframe/Timeservice; #How many attempts can be serviced until a new local even rises
      M=100; #Total local memory in Blocks
      N=0; #Total nodes in known neighbourhood
      W=0; #Total number of neighbors I want to try to inform of my event
      L=3; #The number of Blocks transmitted in a "Verify me" message
      
      TLocalSearch = Tverify+(M/2)*0.2; #Estimation of Local chain generic search for a block in millis()
 
 for Ni=100:100 #for only two devices peering, we set Ni=2
      N=Ni;
      Pwitness = zeros (1,N); # Pwitness corresponds to the actual number of aquired witnesses on a specific Local Event, given W attemts to share it
      TverifyMeMessagePropagation = zeros (1,N);
      ToverheadPoE = zeros (1,N-1);
      ToverheadPoF = zeros (1,N-1);
      ToverheadPoO = zeros (1,N-1);
      ToverheadPoC = zeros (1,N-1);
      ToverheadPoI = zeros (1,N-1);
      TBackPropagate = zeros (1,N-1);
    
      for W=1:(N-1)
        Tclient=(Tsc_Success+Ttransmission); #*W By default the node is listening (server mode). when local event, the node swaps to client mode and transmits
        Pclient= (W*Tclient)/HAT;
        Tserver=Treception+Tverify+Thash+Tsign+Tcopy;
        Pserver=1-Pclient;

        #Estimate witness probability as a function of Timeframe and Nefighboring nodes in network
        
        #Piwitness: Probability that node j becomes witness of the current event on IoT device i 
        #Pwitness: Probability that there is at least one witness other than me
        Piserveothers=0;
        i=(min(W, AttemptsInTimeframe)); #if everyone contacts W neighbors to share a Local Event to find a witness, what Possibility do i have to get at least one?
        for j=2:i
          Piserveothers=Piserveothers+(Pclient/(N-2));
        endfor
        W
        Piwitness=Pserver-Piserveothers;

         Pwitness(W)=0;
         Pwitness(W)=i*Piwitness; #the probability that at least one witness exists
 
 #**************************************
 #Continus Authentication parameters calculation
         TverifyMeMessagePropagation(W)=W*L*(Ttransmission/Piwitness);  #All witnesses must receive the verifyme message. #Transmission/Piwitness attempts to success
         TBackPropagate(W)=(((Ttransmission/Piwitness)*W*L)+(N-W-1)*(Ttransmission/Blocksize*Piwitness))*Tsc_Success;
         ToverheadPoE(W)=TverifyMeMessagePropagation(W)+TLocalSearch+(Ttransmission/Pwitness(W)); #TBackPropagate(W)
         ToverheadPoO(W)=TverifyMeMessagePropagation(W)+TLocalSearch*(L/2)+(Ttransmission/Piwitness);#A random one of the L Blocks is found in a Local chain and is backpropagated. All are responding
         ToverheadPoF(W)=TverifyMeMessagePropagation(W)+TLocalSearch*L+(N-1)*(Ttransmission/Piwitness);#All L blocks are searched. If "even one" is found, it is backpropagated as PoF.
         
      endfor

    plot((ToverheadPoF),'--'); grid on
hold on
    xlabel('Number of Effective Witnessing nodes per realm')
    ylabel('PoF time overhead per request in msec')
    title('Time overhead per Proof of Fallacy verification')
    #labels = {labels{:}, ["Event Period (ms):", num2str(HAT), " Witnesses Probability (N%) : ", num2str(xi/N)]};
    # labels = {labels{:}, ["Number of nodes in neighborhood ", num2str(N), " Witnesses Probability (N%) : ", num2str(xi/N)]};
    # legend (labels, "location", "northeast");

endfor
hold off
