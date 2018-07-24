$ontext
Thesis - Model Draft 10
26-APR-2018 || Joao Felicio

### Initial model
### Adds intercontinental transportation constraints ###
$offtext

*option MIP=cplex;
option iterlim = 900000000;
option reslim = 1728000000;
option solvelink=0;
option optcr=0.1;
option solprint = off;

set      l locations     /i1, i2, i3, i4,
                         f1,
                         w1, w2, w3,
                         j1, j2, j3,
                         airUS, airPT, airBR, airFR,
                         portUS, portPT, portBR, portFR/;
         set sup(l)    suppliers                 /i1, i2, i3, i4/;
         set f(l)      factory                   / f1 /;
         set w(l)      warehouses                /w1, w2, w3/;
         set j(l)      integrator-customer       /j1, j2, j3/;
         set air(l)    airports                  /airUS, airPT, airBR, airFR/;
         set port(l)   seaports                  /portUS, portPT, portBR, portFR/;
         set mtp(l)    Material Transfer Points  / airUS, airPT, airBR, airFR, portUS, portPT, portBR, portFR /;
         set Europe(l) entities in Europe        / i1, i3, f1, w1, airPT, airFR, portPT, portFR /;
         set USA(l)      entities in USA         / i2, i4, w2, airUS, portUS /;
         set Brasil(l)   entities in Brasil      / w3, j1, airBR, portBR /;
         alias(l,lo,ld);

set      gama investments /fac, equip, tru/;

Sets
         a Activity              / a1*a16 /
;

set      trm Transport Modes / truck_own, truck_out, truckCOOL_own, truckCOOL_out, truck_XL_own, truck_XL_out, truckCOOL_XL_own, truckCOOL_XL_out, plane, planeCOOL, boat, boatCOOL, rail, railCOOL /;
         set t_truck(trm)    / truck_own, truck_out, truckCOOL_own, truckCOOL_out, truck_XL_own, truck_XL_out, truckCOOL_XL_own, truckCOOL_XL_out /
         set t_plane(trm)    / plane, planeCOOL /
         set t_boat(trm)     / boat, boatCOOL /
         set t_rail(trm)     / rail, railCOOL /
         set t_cool(trm)     / truckCOOL_own, truckCOOL_out, truckCOOL_XL_own, truckCOOL_XL_out, planeCOOL, boatCOOL /
         set t_nocool(trm)   / truck_own, truck_out, truck_XL_own, truck_XL_out, plane, boat /
         set t_notruck(trm)  / boat, boatCOOL, plane, planeCOOL /
         set t_truckOWN(trm)  / truck_own, truckCOOL_own, truck_XL_own, truckCOOL_XL_own /
;

set      m Materials                                     / rm1, rm2, rm3, rm4, rm5, sp1, sp2, p1, p2, p3, p4 /;
         set rm(m)  raw materials                        / rm1, rm2, rm3, rm4, rm5 /;
         set sp(m)  support materials                    / sp1, sp2 /;
         set mat(m) production materials                 / rm1, rm2, rm3, rm4, rm5, sp1, sp2 /;
         set p(m)   products                             / p1, p2, p3, p4 /;
         set nocool(m)   materials not requiring cool    / rm2, rm5, sp1, sp2 /;
         set cool(m)     materials requiring cool        / rm1, rm3, rm4 /;
         alias(m,mm)
;

set      r Resource                              / o1, o2, o3, o4, l1 /;
         set tech(r)   production technologies   / o1, o2, o3, o4 /
         set lab(r)  labour                      / l1 /
;

set      y Tempo macro /y1*y15/;
         set yFirst(y)   first time period
             yOther(y)   all but first time period
             yLast(y)    final time period;
         yFirst(y)  = yes$(ord(y) eq 1);
         yOther(y)  = not yFirst(y);
         yLast(y)   = yes$(ord(y) eq card(y));

set      t Tempo micro /t1*t12/;
         set tFirst(t,y)   first time period
             tOther(t,y)   all but first time period
             tLast(t,y)    final time period;
         tFirst(t,y)  = yes$(ord(t) eq 1);
         tOther(t,y)  = not tFirst(t,y);
         tLast(t,y)   = yes$(ord(t) eq card(t));

set      d Tempo nano /d1*d12/;
         set dFirst(d,t)   first time period
             dOther(d,t)   all but first time period
             dLast(d,t)    final time period;
         dFirst(d,t)  = yes$(ord(d) eq 1);
         dOther(d,t)  = not dFirst(d,t);
         dLast(d,t)   = yes$(ord(d) eq card(d));

Table noMatTransp(trm,m)         material-transport mode possible connections
                    rm1     rm2     rm3     rm4     rm5     sp1     sp2     p1      p2      p3      p4
truck_own           0       1       0       0       1       1       1       1       1       1       1
truck_out           0       1       0       0       1       1       1       1       1       1       1
truckCOOL_own       1       1       1       1       1       1       1       1       1       1       1
truckCOOL_out       1       1       1       1       1       1       1       1       1       1       1
truck_XL_own        0       1       0       0       1       1       1       1       1       1       1
truck_XL_out        0       1       0       0       1       1       1       1       1       1       1
truckCOOL_XL_own    1       1       1       1       1       1       1       1       1       1       1
truckCOOL_XL_out    1       1       1       1       1       1       1       1       1       1       1
plane               0       1       0       0       1       1       1       1       1       1       1
planeCOOL           1       1       1       1       1       1       1       1       1       1       1
boat                0       1       0       0       1       1       1       1       1       1       1
boatCOOL            1       1       1       1       1       1       1       1       1       1       1
rail                0       0       0       0       0       0       0       0       0       0       0
railCOOL            0       0       0       0       0       0       0       0       0       0       0
;

** Modelo Bruna Mota

set       noSupRM(m,l)           suppliers  and raw materials
          noFactRM(m,l)          factories  and raw materials
          noFactFP(m,l)          factories  and final products
          noWhFP(m,l)            warehouses and final products
          noWhRM(m,l)            warehouses and raw materials
          noAirFP(m,l)           airports   and final products
          noAirRM(m,l)           airports   and raw materials
          noPortFP(m,l)          seaports   and final products
          noPortRM(m,l)          seaports   and raw materials
          noCustFP(m,l)          customers  and final products
          noAll(m,l)             all nodes
*          noMatTranspCool(m,trm)         transport requiring cool
*          noMatTranspNOcool(m,trm)       transport not requiring cool
          noTrans(m,l)           ??
;
          noSupRM(m,l)           =yes$(mat(m)    and sup(l));
          noFactRM(m,l)          =yes$(mat(m)    and f(l));
          noFactFP(m,l)          =yes$(p(m)      and f(l));
          noWhFP(m,l)            =yes$(p(m)      and w(l));
          noWhRM(m,l)            =yes$(mat(m)    and w(l));
          noAirFP(m,l)           =yes$(p(m)      and air(l));
          noPortFP(m,l)          =yes$(p(m)      and port(l));
          noAirRM(m,l)           =yes$(mat(m)    and air(l));
          noPortRM(m,l)          =yes$(mat(m)    and port(l));
          noCustFP(m,l)          =yes$(p(m)      and j(l));
          noAll(m,l)     =noSupRM(m,l)+noFactRM(m,l)+noFactFP(m,l)+noWhFP(m,l)+noWhRM(m,l)+noAirFP(m,l)
                         +noPortFP(m,l)+noAirRM(m,l)+noPortRM(m,l)+noCustFP(m,l);

*          noMatTranspCool(m,trm)     =yes$(cool(m)       and     t_cool(trm));
*          noMatTranspNOcool(m,trm)   =yes$(nocool(m)     and     (not (t_cool(trm))));

set      arcSupFact(lo,ld)       suppliers  to factories
         arcSupWh(lo,ld)         suppliers  to warehouse
         arcSupAir(lo,ld)        supplier   to airport
         arcSupPort(lo,ld)       supplier   to seaport
         arcFactWh(lo,ld)        factories  to warehouses
         arcFactAir(lo,ld)       factories  to airports
         arcFactPort(lo,ld)      factories  to seaports
         arcFactCust(lo,ld)      factories  to customers
         arcWhFact(lo,ld)        warehouses to factories
         arcWhWh(lo,ld)          warehouses to warehouses
         arcWhAir(lo,ld)         warehouses to airports
         arcWhPort(lo,ld)        warehouses to seaports
         arcWhCust(lo,ld)        warehouses to customers
         arcAirFact(lo,ld)       airports   to factories
         arcAirWh(lo,ld)         airports   to warehouses
         arcAirAir(lo,ld)        airports   to airports
         arcAirPort(lo,ld)       airports   to seaports
         arcAirCust(lo,ld)       airports   to customers
         arcPortFact(lo,ld)      seaports   to factories
         arcPortWh(lo,ld)        seaports   to warehouses
         arcPortAir(lo,ld)       seaports   to airports
         arcPortPort(lo,ld)      seaports   to seaports
         arcPortCust(lo,ld)      seaports   to customers

         arcUSA_EUR(lo,ld)       arc USA    to Europe....
         arcUSA_BRA(lo,ld)       arc
         arcBRA_EUR(lo,ld)       arc
         arcBRA_USA(lo,ld)       arc
         arcEUR_EUR(lo,ld)       arc
         arcEUR_USA(lo,ld)       arc
         arcEUR_BRA(lo,ld)       arc
         arcInterCont(lo,ld)     arcs that require air or plane intercontinental
         arcEUR_EUR(lo,ld)       arc
         arcUSA_USA(lo,ld)       arc
         arcBRA_BRA(lo,ld)       arc
         arcIntraCont(lo,ld)     arcs possible by truck - intracontinental
         arcAll(lo,ld)           all arcs
;
         arcSupFact(lo,ld)       =yes$(sup(lo)  and f(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcSupWh(lo,ld)         =yes$(sup(lo)  and w(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcSupAir(lo,ld)        =yes$(sup(lo)  and air(ld)  and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcSupPort(lo,ld)       =yes$(sup(lo)  and port(ld) and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcFactWh(lo,ld)        =yes$(f(lo)    and w(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcFactAir(lo,ld)       =yes$(f(lo)    and air(ld)  and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcFactPort(lo,ld)      =yes$(f(lo)    and port(ld) and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcFactCust(lo,ld)      =yes$(f(lo)    and j(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcWhFact(lo,ld)        =yes$(w(lo)    and f(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcWhWh(lo,ld)          =yes$(w(lo)    and w(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))) and not sameas(lo,ld));
         arcWhAir(lo,ld)         =yes$(w(lo)    and air(ld)  and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcWhPort(lo,ld)        =yes$(w(lo)    and port(ld) and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcWhCust(lo,ld)        =yes$(w(lo)    and j(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcAirFact(lo,ld)       =yes$(air(lo)  and f(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcAirWh(lo,ld)         =yes$(air(lo)  and w(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcAirAir(lo,ld)        =yes$(air(lo)  and air(ld)  and not sameas(lo,ld));
         arcAirPort(lo,ld)       =yes$(air(lo)  and port(ld) and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcAirCust(lo,ld)       =yes$(air(lo)  and j(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcPortFact(lo,ld)      =yes$(port(lo) and f(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcPortWh(lo,ld)        =yes$(port(lo) and w(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcPortAir(lo,ld)       =yes$(port(lo) and air(ld)  and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));
         arcPortPort(lo,ld)      =yes$(port(lo) and port(ld) and not sameas(lo,ld));
         arcPortCust(lo,ld)      =yes$(port(lo) and j(ld)    and ((Europe(lo) and Europe(ld)) or (USA(lo) and USA(ld)) or (Brasil(lo) and Brasil(ld))));

         arcUSA_EUR(lo,ld)       =yes$(USA(lo)     and Europe(ld));
         arcUSA_BRA(lo,ld)       =yes$(USA(lo)     and Brasil(ld));
         arcBRA_EUR(lo,ld)       =yes$(Brasil(lo)  and Europe(ld));
         arcBRA_USA(lo,ld)       =yes$(Brasil(lo)  and USA(ld));
         arcEUR_EUR(lo,ld)       =yes$(Europe(lo)  and Europe(ld));
         arcEUR_USA(lo,ld)       =yes$(Europe(lo)  and USA(ld));
         arcEUR_BRA(lo,ld)       =yes$(Europe(lo)  and USA(ld));
         arcInterCont(lo,ld)     =arcUSA_EUR(lo,ld)+arcUSA_BRA(lo,ld)+arcBRA_EUR(lo,ld)+arcBRA_USA(lo,ld)+arcEUR_USA(lo,ld);
         arcEUR_EUR(lo,ld)       =yes$(Europe(lo) and Europe(ld));
         arcUSA_USA(lo,ld)       =yes$(USA(lo) and USA(ld));
         arcBRA_BRA(lo,ld)       =yes$(Brasil(lo) and Brasil(ld));
         arcIntraCont(lo,ld)     =yes$(arcEUR_EUR(lo,ld) + arcUSA_USA(lo,ld) + arcBRA_BRA(lo,ld));
         arcAll(lo,ld)           =arcSupFact(lo,ld)+arcFactWh(lo,ld)+arcFactAir(lo,ld)+arcFactPort(lo,ld)+arcFactCust(lo,ld)
                                 +arcWhFact(lo,ld)+arcWhWh(lo,ld)+arcWhAir(lo,ld)+arcWhPort(lo,ld)+arcWhCust(lo,ld)+arcAirFact(lo,ld)
                                 +arcAirWh(lo,ld)+arcAirAir(lo,ld)+arcAirPort(lo,ld)+arcAirCust(lo,ld)+arcPortFact(lo,ld)+arcPortWh(lo,ld)
                                 +arcPortAir(lo,ld)+arcPortPort(lo,ld)+arcPortCust(lo,ld);
*display arcInterCont;

set      flowOUTsupRM(m,lo,ld)         flow from suppliers
         flowINfactRM(m,lo,ld)         flow of raw materials      to factories
         flowOUTfactFP(m,lo,ld)        flow of final products     from factories
         flowINwhFP(m,lo,ld)           flow of final products     to warehouses
         flowINwhRM(m,lo,ld)           flow of raw materials      to warehouses
         flowOUTwhFP(m,lo,ld)          flow of final products     from warehouses
         flowOUTwhRM(m,lo,ld)          flow of raw materials      from warehouses
         flowINairFP(m,lo,ld)          flow of final products     to airports
         flowOUTairFP(m,lo,ld)         flow of final products     from airports
         flowINairRM(m,lo,ld)          flow of raw materials      to airports
         flowOUTairRM(m,lo,ld)         flow of raw materials      from airports
         flowINportFP(m,lo,ld)         flow of final products     to seaports
         flowOUTportFP(m,lo,ld)        flow of final products     from seaports
         flowINportRM(m,lo,ld)         flow of raw materials      to seaports
         flowOUTportRM(m,lo,ld)        flow of raw materials      from seaports
         flowINcustFP(m,lo,ld)         flow of final products     to clients
         network(m,lo,ld)              all flows
;

         flowOUTsupRM(m,lo,ld)           =yes$(noSupRM(m,lo)     and (arcSupFact(lo,ld)  or arcSupAir(lo,ld)     or arcSupPort(lo,ld)    or arcSupWh(lo,ld)));
         flowINfactRM(m,lo,ld)           =yes$(noFactRM(m,ld)    and (arcSupFact(lo,ld)  or arcAirFact(lo,ld)    or arcPortFact(lo,ld)   or arcWhFact(lo,ld)));
         flowOUTfactFP(m,lo,ld)          =yes$(noFactFP(m,lo)    and (arcFactWh(lo,ld)   or arcFactPort(lo,ld)   or arcFactAir(lo,ld)    or arcFactCust(lo,ld)));
         flowINwhFP(m,lo,ld)             =yes$(noWhFP(m,ld)      and (arcFactWh(lo,ld)   or arcWhWh(lo,ld)       or arcAirWh(lo,ld)      or arcPortWh(lo,ld)));
         flowINwhRM(m,lo,ld)             =yes$(noWhRM(m,ld)      and (arcSupWh(lo,ld)    or arcWhWh(lo,ld)       or arcAirWh(lo,ld)      or arcPortWh(lo,ld)));
         flowOUTwhFP(m,lo,ld)            =yes$(noWhFP(m,lo)      and (arcWhWh(lo,ld)     or arcWhAir(lo,ld)      or arcWhPort(lo,ld)     or arcWhCust(lo,ld)));
         flowOUTwhRM(m,lo,ld)            =yes$(noWhRM(m,lo)      and (arcWhWh(lo,ld)     or arcWhAir(lo,ld)      or arcWhPort(lo,ld)     or arcWhFact(lo,ld)));
         flowINairFP(m,lo,ld)            =yes$(noAirFP(m,ld)     and (arcFactAir(lo,ld)  or arcWhAir(lo,ld)      or arcAirAir(lo,ld)     or arcPortAir(lo,ld)));
         flowOUTairFP(m,lo,ld)           =yes$(noAirFP(m,lo)     and (arcAirWh(lo,ld)    or arcAirAir(lo,ld)     or arcAirPort(lo,ld)    or arcAirCust(lo,ld)));
         flowINairRM(m,lo,ld)            =yes$(noAirRM(m,ld)     and (arcSupAir(lo,ld)   or arcWhAir(lo,ld)      or arcAirAir(lo,ld)     or arcPortAir(lo,ld)));
         flowOUTairRM(m,lo,ld)           =yes$(noAirRM(m,lo)     and (arcAirWh(lo,ld)    or arcAirAir(lo,ld)     or arcAirPort(lo,ld)    or arcAirFact(lo,ld)));
         flowINportFP(m,lo,ld)           =yes$(noPortFP(m,ld)    and (arcFactPort(lo,ld) or arcWhPort(lo,ld)     or arcPortPort(lo,ld)   or arcAirPort(lo,ld)));
         flowOUTportFP(m,lo,ld)          =yes$(noPortFP(m,lo)    and (arcPortWh(lo,ld)   or arcPortPort(lo,ld)   or arcPortAir(lo,ld)    or arcPortCust(lo,ld)));
         flowINportRM(m,lo,ld)           =yes$(noPortRM(m,ld)    and (arcSupPort(lo,ld)  or arcWhPort(lo,ld)     or arcPortPort(lo,ld)   or arcAirPort(lo,ld)));
         flowOUTportRM(m,lo,ld)          =yes$(noPortRM(m,lo)    and (arcPortWh(lo,ld)   or arcPortPort(lo,ld)   or arcPortAir(lo,ld)    or arcPortFact(lo,ld)));
         flowINcustFP(m,lo,ld)           =yes$(noCustFP(m,ld)    and (arcFactCust(lo,ld) or arcWhCust(lo,ld)     or arcAirCust(lo,ld)    or arcPortCust(lo,ld)));
         network(m,lo,ld)                =flowOUTsupRM(m,lo,ld)+flowINfactRM(m,lo,ld)+flowOUTfactFP(m,lo,ld)+flowINwhFP(m,lo,ld)
                                         +flowINwhRM(m,lo,ld)+flowOUTwhFP(m,lo,ld)+flowOUTwhRM(m,lo,ld)+flowINairFP(m,lo,ld)
                                         +flowOUTairFP(m,lo,ld)+flowINairRM(m,lo,ld)+flowOUTairRM(m,lo,ld)+flowINportFP(m,lo,ld)
                                         +flowOUTportFP(m,lo,ld)+flowINportRM(m,lo,ld)+flowOUTportRM(m,lo,ld)+flowINcustFP(m,lo,ld);

set      flowOnlyPlane(trm,lo,ld)    connection between airports only by plane
         flowOnlyBoat(trm,lo,ld)     connection between seaports only by boat
         flowOnlyTruck(trm,lo,ld)    connections only by truck
         flowIntraCont(trm,lo,ld)    connections only by truck
         flowInterCont(trm,lo,ld)    connections by plane or boat
         flowAllConnections(trm,lo,ld) all connections allowed
         networkConnected(trm,m,lo,ld) all connections allowed with corresponding products
*         networkIntraConnected(trm,m,lo,ld)
*         networkInterConnected(trm,m,lo,ld)
;
         flowOnlyPlane(trm,lo,ld)    =yes$(t_plane(trm)  and arcAirAir(lo,ld));
         flowOnlyBoat(trm,lo,ld)     =yes$(t_boat(trm)   and arcPortPort(lo,ld));
         flowOnlyTruck(trm,lo,ld)    =yes$(t_truck(trm)  and (arcall(lo,ld) and not (arcAirAir(lo,ld) or arcPortPort(lo,ld))));
         flowAllConnections(trm,lo,ld) =flowOnlyPlane(trm,lo,ld) + flowOnlyBoat(trm,lo,ld) + flowOnlyTruck(trm,lo,ld);
         flowInterCont(trm,lo,ld)    =yes$((flowOnlyPlane(trm,lo,ld) or flowOnlyBoat(trm,lo,ld)) and arcInterCont(lo,ld));
         flowIntraCont(trm,lo,ld)    =yes$((flowOnlyTruck(trm,lo,ld)) and arcIntraCont(lo,ld));
         networkConnected(trm,m,lo,ld) =yes$(network(m,lo,ld) and flowAllConnections(trm,lo,ld) and noMatTransp(trm,m));
*         networkIntraConnected(trm,m,lo,ld) =yes$(network(m,lo,ld) and flowIntraCont(trm,lo,ld));
*         networkInterConnected(trm,m,lo,ld) =yes$(network(m,lo,ld) and flowInterCont(trm,lo,ld));
*         networkConnected(trm,m,lo,ld) =yes$(networkIntraConnected(trm,m,lo,ld) + networkInterConnected(trm,m,lo,ld));

*display arcInterCont, arcIntraCont, flowIntraCont, flowInterCont, networkIntraConnected, networkInterConnected, networkConnected;




Table        dist(l,l)       distance between l and l (in KM)
         i1      i2      i3      i4      f1      w1      w2      w3      j1      j2      j3      airUS   airPT   airBR   airFR   portUS  portPT  portBR  portFR
i1       0       01409   01310   01075   01655   01665   00540   01382   00327   00554   00404   00853   00976   01545   00369   00426   00789   01168   00310
i2               0       01100   00703   01425   00199   00938   00720   00313   01532   01879   00025   01836   00228   01451   00052   01460   00626   01126
i3                       0       01096   01716   01858   01964   01644   00605   01190   00904   00292   01596   01687   00476   01574   01751   00284   00682
i4                               0       01489   00006   01516   00989   00036   00896   00848   01930   01216   01887   01345   01502   00498   01510   01943
f1                                       0       00546   01132   00471   01347   01939   00440   01958   00134   01351   01892   01210   00134   01143   00770
w1                                               0       00164   00538   01919   00952   00337   00992   01562   00448   01948   00139   01451   01071   00254
w2                                                       0       00397   01005   00412   00537   01707   01321   00692   01338   01719   00383   00279   01215
w3                                                               0       00389   00188   01323   00659   01814   01483   01411   00598   01468   01638   01605
j1                                                                       0       01552   00370   01109   00722   00863   00634   00925   00332   00306   01628
j2                                                                               0       01074   00928   00344   01886   01101   00671   00805   01479   01014
j3                                                                                       0       01348   00301   00410   01283   00906   00565   01962   00384
airUS                                                                                            0       00568   01944   00757   01898   00991   01678   01103
airPT                                                                                                    0       00582   01720   01543   00427   01137   00322
airBR                                                                                                            0       01155   00550   00187   01433   01435
airFR                                                                                                                    0       00751   01994   00278   00590
portUS                                                                                                                           0       13210   09784   01469
portPT                                                                                                                                   0       00901   01800
portBR                                                                                                                                           0       02716
portFR                                                                                                                                                   0
;
*port FR - Fos sur Mer - via SeaRates.com
Table     pInitStock(m,l)            Initial stock of product m at entity i
        w1       w2      w3      f1
rm1     0        0       0       0
rm2     0        0       0       0
rm3     0        0       0       0
rm4     0        0       0       0
rm5     0        0       0       0
sp1     0        0       0       0
sp2     0        0       0       0
p1      0        0       0       0
p2      0        0       0       0
p3      0        0       0       0
p4      0        0       0       0
;

* usando os dados do Dinis:

Scalar
rej_rate                 Part rejection rate                             / .10 /
hours_shift              Hours per shift                                 / 8 /
shifts_day               Shifts per day                                  / 1 /
day_month                Avg. Days per month                             / 21 /
bigM                     Big value                                       / 10000000 /
testbeds                 Nr testbeds per aircraft part (18x5)            / 1200 /
scaleUpMult              Scale-up Multiplier                             / 1200 /
cellCapacity             Cell capacity in kgs                            / 100 /
costCell                 Cost per storage cell open                      / 50 /
discountRate             Discount rate                                   / .092 /
taxRate                  Tax rate                                        / .3/
projectLifetime          Project lifetime in years                       / 15 /
amortizationPeriod                                                       / 15 /
salesIncrease            Sales increase per year                         / .0266 /
costIncrease             Cost increase per year                          / .0266 /
convertKWH_CO2           Convert kWh to eq. CO2                          / .537  /
;

*SWITCHES
Scalar
SW1              include facility investment costs        / Yes /
SW2              include equipment investment costs       / Yes /
SW3              include tooling investment costs         / No /
SW4              include other fixed costs                / No /
SW5              include total fixed costs                / Yes /
SW6              include batch fixed costs                / Yes /
SW7              include variable costs                   / Yes /
;

Parameters
sup_capacity(l)          Capacity of Supplier i                  / i1 100000, i2 100000, i3 100000, i4 100000 /
sup_minimum(l)           Minimum quantity of Supplier i          / i1 1, i2 1, i3 1, i4 1 /
plant_capacity(l)        Capacity of plant f                     / f1 2244984 /
maxWhCapacity(w)                                                 / w1 10000, w2 10000, w3 10000 /
minWhCapacity(w)                                                 / w1 1, w2 1, w3 1 /
lot_size(m)              Lot size of material m                  / rm1 3, rm2 6, rm3 4, rm4 5, rm5 1, sp1 5, sp2 6 /
rate_resource(r)         Rate of resource r                      / o1 70, o2 20, o3 90, o4 5, l1 25 /
fixed_equip(r)           Fixed costs of equipment per r          / o1 2360000, o2 427537, o3 1043189, o4 314986, l1 0 /
fixed_facility(l)        Fixed costs of facility per f           / f1 500000, w1 500000, w2 500000, w3 500000 /
fixed_tooling(p)         Fixed costs of tooling per p            / p1 1000, p2 500, p3 800, p4 2000 /
fixed_other(l)           Other fixed costs per f                 / f1 50000 /
res_prod(r)              Resource productivity                   / o1 0.9, o2 0.9, o3 0.9, o4 0.9, l1 0.78 /
holding_cost(m)          Holding cost of material m              / rm1 100, rm2 100, rm3 100, rm4 100, rm5 100, sp1 100, sp2 100, p1 100, p2 100, p3 100, p4 100 /
holding_impact(m)        Env. impact of holding material m       / rm1 100, rm2 100, rm3 100, rm4 100, rm5 100, sp1 100, sp2 100, p1 100, p2 100, p3 100, p4 100 /
nominalWeight(m)         Nominal weight m2 to kg                 / rm1 0.294, rm2 0.194, rm3 1, rm4 0.134, rm5 1, sp1 1, sp2 1, p1 1, p2 1, p3 1, p4 1 /
revenueAnnual(y)         Revenue per year                        / y1 0, y2 0, y3 0, y4 0, y5 0, y6 0, y7 0, y8 0, y9 0, y10 0, y11 0, y12 0, y13 0, y14 0, y15 0 /
product(p)               Products allowed                        / p1 1, p2 1, p3 1, p4 1 /
;

Table    demand(l,t)     Monthly Demand of aircraft parts for Integrator j
         t1      t2      t3      t4      t5      t6      t7      t8      t9      t10     t11     t12
j1       17      17      17      17      17      17      17      17      17      17      17      17
;

Table    pBOM(m,p)       BOM for product p in quantity
        p1       p2      p3      p4
rm1     1.63      0       0       0
rm2     0        3.19    0       0
rm3     0        0.14    0       0
rm4     0        0       1.55    0
rm5     0        0       0       0.4
sp1     0.5      0.5     0.5     0.5
sp2     1.5      1.5     1.5     1.5
;


Table    pTOP(a,p)      Time per process in activity a for product p
         p1      p2      p3      p4
a1       0       0.88    0.5     2
a2       1.02    2.33    0.67    2.25
a3       0       0       0       1.08
a4       0       0       0       0
a5       0       0       0       0
a6       0       0.83    0.83    0
a7       0       0.67    0       0
a8       0       0       0       0.5
a9       5.33    4.25    7.08    0
a10      0       0       0       0
a11      0.17    0.17    0.17    0.17
a12      0       0       0       0
a13      0       0       0       0
a14      0       0       0       0
a15      0       0       0       0
a16      0       0       0       0
;

* a1 - tool preparation; a2 - material preparation; a3 - pre-heating; a4 - lay-up;
* a5 - additives (e.g., honeycomb); a6 - vacuum bagging; a7 - resin infusion; a8 - apply pressure (hot press);
* a9 - curing; a10 - debagging/demoulding; a11 - machining (cutting, drilling, routing, trimming, sanding);
* a12 - joining; a13 - finishing; a14 - NDT/quality inspection; a15 - assembly; a16 - painting;

*(o1 - autoclave; o2 - oven; o3 - press; o4 - vacuum; l1 - labour)

Table    pBOT(r,p,a)   Quantity of resource r needed to product p and activity a (per batch)
         a1      a2      a3      a4      a5      a6      a7      a8      a9      a10     a11     a12     a13     a14     a15     a16
o1.p1    0       0       0       0       0       0       0       0       1       0       0       0       0       0       0       0
o2.p1    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o3.p1    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o4.p1    0       0       0       0       0       0       0       0       1       0       0       0       0       0       0       0
l1.p1    1       1       0       1       0       0       0       0       0       0       1       0       0       0       0       0
o1.p2    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o2.p2    1       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o3.p2    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o4.p2    0       0       0       0       0       1       0       0       0       0       0       0       0       0       0       0
l1.p2    1       1       0       0       0       0       0       0       0       0       1       0       0       0       0       0
o1.p3    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o2.p3    1       0       0       0       0       0       0       0       1       0       0       0       0       0       0       0
o3.p3    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o4.p3    0       0       0       0       0       1       0       0       1       0       0       0       0       0       0       0
l1.p3    1       1       0       0       0       0       0       0       0       0       1       0       0       0       0       0
o1.p4    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
o2.p4    0       0       1       0       0       0       0       0       0       0       0       0       0       0       0       0
o3.p4    0       0       0       0       0       0       0       1       0       0       0       0       0       0       0       0
o4.p4    0       0       0       0       0       0       0       0       0       0       0       0       0       0       0       0
l1.p4    1       1       0       0       0       0       0       0       0       0       1       0       0       0       0       0
;

Table    pNBatch(a,p)   Batch size per activity and per product scenario
         p1      p2      p3      p4
a1       1       1       1       1
a2       1       1       1       1
a3       1       1       1       1
a4       1       1       1       1
a5       1       1       1       1
a6       1       1       1       1
a7       1       1       1       1
a8       1       1       1       1
a9       1       1       1       1
a10      1       1       1       1
a11      1       1       1       1
a12      1       1       1       1
a13      1       1       1       1
a14      1       1       1       1
a15      1       1       1       1
a16      1       1       1       1
;

Table    pScaleUp(a,p)   Scale-up Factor
         p1      p2      p3      p4
a1       1       1       1       1
a2       1       1       1       1
a3       1       1       1       1
a4       1       1       1       1
a5       1       1       1       1
a6       1       1       1       1
a7       1       1       1       1
a8       1       1       1       1
a9       1       1       1       1
a10      1       1       1       1
a11      1       1       1       1
a12      1       1       1       1
a13      1       1       1       1
a14      1       1       1       1
a15      1       1       1       1
a16      1       1       1       1
;

Table    mCost(m,sup)    Cost of material m from supplier i
        i1       i2      i3      i4
rm1     60.78    10000   90.8    57.5
rm2     37.49    10000   56.1    38.3
rm3     71.40    10000   81.3    75.9
rm4     64.68    10000   61.5    72.4
rm5     10000    204.14  205.3   230.6
sp1     15       10000   10      13
sp2     1.25     10000   1.30    2
;

Table    pSupply(m,l)
         i1      i2      i3      i4
rm1      1       0       1       1
rm2      1       0       1       1
rm3      1       0       1       1
rm4      1       0       1       1
rm5      0       1       0       0
sp1      1       0       1       1
sp2      1       0       1       1
;

parameter pSalvage(gama)  Salvage value for each investment at the end of the 15 years
                   /fac  0.55
                   equip 0
                   tru   0/
;

table     pDepreciationRate(gama,y)     Depreciation rate at time period t of each type of investment gama
         y1      y2      y3      y4      y5      y6      y7      y8      y9      y10     y11     y12     y13     y14     y15
fac      0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.01    0.01    0.01    0.01    0.01
equip    0.125   0.125   0.125   0.125   0.125   0.125   0.125   0.125   0       0       0       0       0       0       0
tru      0.2     0.2     0.2     0.2     0.2     0       0       0       0       0       0       0       0       0       0
;


* ### Product characterization ###
parameter        pAreaUnit(p)            Necessary area per product unit
                 / p1 0.001
                 p2 0.001
                 p3 0.001
                 p4 0.001 /
                 pProductWeight(m)       Weight of product p
                 / p1 3000
                 p2 3000
                 p3 3000
                 p4 3000 /
                 mAreaUnit(m)            Necessary area per material unit
                 / rm1 0.002
                 rm2 0.001
                 rm3 0.004
                 rm4 0.003
                 rm5 0.007
                 sp2 0.009
                 sp1 0.007 /
;

* ### TRANSPORT MODES ###
parameter
          pTranspCapProd(trm)           Capacity of transportation mode a per time period in units of product
          /truck_own 0
           truck_out 0
           truck_XL_own 4
           truck_XL_out 4
           plane  20
           boat   80
           truckCOOL_own 0
           truckCOOL_out 0
           truckCOOL_XL_own 4
           truckCOOL_XL_out 4
           planeCOOL  20
           boatCOOL   80/
          pTranspCapMat(trm)           Capacity of transportation mode a per time period in weight
          /truck_own 24000
           truck_out 24000
           truck_XL_own 40000
           truck_XL_out 40000
           plane  120000
           boat   480000
           truckCOOL_own 23000
           truckCOOL_out 23000
           truckCOOL_XL_own 38000
           truckCOOL_XL_out 38000
           planeCOOL  120000
           boatCOOL   480000/
          pCapMin(trm)              Minimum cargo to be transported
          /truck_own 1
           truck_out 1
           truck_XL_own 1
           truck_XL_out 1
           plane  1
           boat   1
           truckCOOL_own 1
           truckCOOL_out 1
           truckCOOL_XL_own 1
           truckCOOL_XL_out 1
           planeCOOL  1
           boatCOOL   1/
          pTranspAcquire(trm)
          /truck_own     80000
          truckCOOL_own  100000
          truck_XL_own     800000
          truckCOOL_XL_own  1000000/
          pAnnualContract(trm)     Contract costs for outsourced transportation
          /truck_out     10000
           truckCOOL_out 15000
           truck_XL_out     20000
           truckCOOL_XL_out 30000
           plane         50000
           planeCOOL     70000
           boat          70000
           boatCOOL      80000/
         pCarrierMaxContract(trm)      Carrier annual maximum nr of trips
          /truck_out     1000
           truckCOOL_out 1000
           truck_XL_out     1000
           truckCOOL_XL_out 1000
           plane         100
           planeCOOL     100
           boat          100
           boatCOOL      100/
          pTripRate(trm)                 Rate per trip of outsourced transportation
          /truck_out     2000
           truckCOOL_out 3000
           truck_XL_out     3000
           truckCOOL_XL_out 4000
           plane         15000
           planeCOOL     20000
           boat          10000
           boatCOOL      15000/
          pHubFixedCost(l)        Fixed hub terminal cost (contracted)
          /airUS         216000
           airPT         252000
           airBR         252000
           airFR         144000
           portUS        288000
           portPT        144000
           portBR        200100
           portFR        150000/
          pHubVarCost(l)          Handling cost per unit at hub terminals
          /airUS         0.1
           airPT         0.125
           airBR         0.125
           airFR         0.13
           portUS        0.15
           portPT        0.12
           portBR        0.13
           portFR        0.17/

          pVarTranspCost(trm)       Transport cost for transportation mode a per kg.km

          pNumberWorkersTransp(trm) Number of workers necessary for each transportation mode
          /truck_own 1
           truck_out 1
           truck_XL_own 1
           truck_XL_out 1
           plane  2.53E-7
           boat   8.63E-11
           truckCOOL_own 1.5
           truckCOOL_out 1.5
           truckCOOL_XL_own 1.5
           truckCOOL_XL_out 1.5
           planeCOOL  2.53E-6
           boatCOOL   8.63E-10/
          pVehCo(trm)               Average vehicle consumption (L per 100km)
          /truck_own 30
           truck_out 31
           truckCOOL_own 31
           truckCOOL_out 32
           truck_XL_own 32
           truck_XL_out 33
           truckCOOL_XL_own 33
           truckCOOL_XL_out 35/

          pMaxTruckInv            Maximum investment in trucks           / 2000000 /
          pFPrice                 Fuel price (eur per L)                  / 1.4 /
          pVehMa                  Maintenance costs (eur per km)-includes tyres and service-does not include worker  / 0.3 /
          pAVS                    Average speed                         / 60 /
          pMaxDriveHoursperWeek   Maximum driving hours per week        / 45 /
          pWeeksperTimePeriod     Weeks per time period                 / 4 /
          pWeeklyWorkingHours     Weekly working hours                  / 40 /
          ;
          pVarTranspCost(t_truck)=pVehCo(t_truck)*pFPrice*0.01 + pVehMa;
          pVarTranspCost('plane')=0.04;
          pVarTranspCost('planeCOOL')=0.04*(1.1);
          pVarTranspCost('boat')=0.01;
          pVarTranspCost('boatCOOL')=0.01*(1.1);


* #################################################################################################################################################


Variables
*Inflow(sup,f,m,d,t)      Inbound flow of material m from supplier i to plant f in period t (in weight area or units)
Flow(lo,ld,m,trm,t,y)            Flow of material m from l.origin to l.destination in period t (in units)
*TransFlow(trm,lo,ld,m,d,t)      Transportation flow of material m from l.origin to l.dest. in period t (in units)
Production(l,p,t,y)              Production at plant f of product p in day d
MatOrder(lo,ld,m,t,y)            Order quantity of material m from supplier i to plant f in day d (in units)
Open(l)                          Equal to 1 if plant f is open
Forming(p)                       Forming scenario s is active
Manuf_NrResource(r,t,y)          Number of resources to hire for line f in period t
StockLevel(l,m,t,y)              Amount of material m stored in facility w in day d
Source(sup,t,y)                  Supplier sup is used
NrTrips(trm,lo,ld,t,y)           Number of trips with transportation mode trm between entity lo and entity ld in time period (dt)
TrucksMonth(trm,l,t,y)           Number of transportation modes trm necessary in entity lo in time period dt
Trucks(trm,l)                    Number of transportation modes trm necessary in entity lo in total
Cell(l,m,y)                      Number of storage cells open at warehouse l with material m
TranspUsed(trm)                  Transports used

* For the objective function:
Z objective variable
vNPV                        Expected Profit
vCashFlow(y)                Cash Flow
vNetEarn(y)                 Net earnings
vDepCap(y)                  Depreciation of the capital in time period t
vFixedCapInvest(gama)       Fixed capital investment of each investment gama
vFixedCapInvTotal           Total fixed capital investment

varAnnualCosts(y)           Annual variable costs
manuf_fixed_cost            Investment fixed costs of manufacturing
manuf_var_cost(y)           Variable costs of manufacturing
transp_fixed_cost(y)        Fixed cost of transportation
transp_var_cost(y)          Variable costs of transportation
store_fixed_cost(y)         Fixed cost of storage
store_var_cost(y)           Variable costs of storage
;
positive variable vDepCap, vFixedCapInvTotal, vFixedCapInvest, varAnnualCosts, manuf_fixed_cost, manuf_var_cost, transp_fixed_cost, transp_var_cost, store_fixed_cost, store_var_cost;
negative variable vNPV, vCashFlow, vNetEarn;
positive variable Manuf_NrResource, Production, Flow, MatOrder, StockLevel;
positive variable NrTrips, TrucksMonth, Trucks;
binary variable Open, Source, Forming, TranspUsed;
positive variable Cell;

Equations
* inbound=production
*         eq1(sup,l,mat,t,y)           Material balance inbound
* relation weight-area to units
*         eq2(sup,mat,t,y)             Relation to units - ordered quantity
* respect supplier i capacity
*         eq3(sup,t,y)                 Respect supplier capacity
* respect supplier i minimum order quantity
*         eq4(sup,t,y)               Respect supplier minimum quantity
* respect market demand
*         eq5(j,t,y)                 Respect market demand
* production=outbound
*         eq6(ld,p,t,y)             Material balance outbound
*activate forming scenarios
*         eq7(f,p)                 Activate forming scenarios with production
*         eq7a(f,ld,trm,p)           Activate forming scenarios with flow
* only one active forming scenario
*         eq10                     Scenarios
* Production capacity
*         eq11(p,f,r,t,y)            Production capacity

         eq5(ld,t,y)             Demand
         eq7a(f,p)                 Activate forming scenarios with production
         eq7b(l,p)
         eq7c(f,ld,trm,p)           Activate forming scenarios with flow
         eq10                     Scenarios
         eq11(f,p,r,t,y)            Production capacity limited to resources

*Balance at factories
         eEQ1(p,l,t,y)
         eEQ1a(p,l,t,y)
         eEQ2(mat,l,t,y)
         eEQ2a(mat,l,t,y)
*         eEQ2(m,l,t,y)
         eEQ3(m,lo,ld,t,y)
* Balance at warehouses
        eq12a(m,w,t,y)           Balance at warehouses - period 0
        eq12b(m,w,t,y)           Balance at warehouses - other periods
        eq12c(w,y)               stocklevel max
        eq12d(w,y)               stocklevel min

*Flow if open
*         eEQ36(trm,lo,ld,t,y)
*         eEQ37(trm,lo,ld,t,y)

* #### TRANSPORTATION ###
*Transportation physical constraints:
*          eEQ22(m,l,t,y)         What goes to an airport must be transported by plane to another airport
*          eEQ23(m,l,t,y)         What goes to a seaport must be transported by boat to another seaport
*Necessary number of trips:
          eEQ24a(trm,lo,ld,t,y)  Necessary number of trips according to transport mode's maximum capacity for raw materials
          eEQ24b(trm,lo,ld,t,y)   Necessary number of trips according to transport mode's maximum capacity for finished products

          eEQ25(trm,lo,ld,t,y)   Minimum cargo in each transport mode
          eEQ26(trm,lo,ld,t,y)   Transp Used
          eEQ27(trm,lo,ld,t,y)   Q only if Y

*Limits contracted capacity with air and sea carrier:
          eEQ28(trm,lo,ld,y)   Maximum trips contracted with carrier per time period
*Necessary number of transportation modes:
          eEQ29(trm,l,t,y)       Necessary number of trucks in each time period
          eEQ30(trm,l,t,y)       Necessary number of trucks in each entity for all time horizon
          eEQ31                  Maximum investment in road transportation
          eEQ32(trm,l,y)           K only if Y
*          eEQ33(trm,l,y)           K only if X

*Cross-docking at airports
        e13(m,air,t,y)
*Cross-docking at seaports
        e14(m,port,t,y)

          eNPV              Net Present Value
          eCF(y)            Cash flow
          eCFlast(y)        Cash flow in the final time period
          eNE(y)            Net earnings
          eDP(y)            Depreciation of the capital in time period t
          eFCIfac           Fixed capital investment in entities
          eFCIequip         Fixed capital investment in technologies
          eFCItrucks        Fixed capital investment in trucks
          eFCItotal         FCI total


* objective function: investment fixed costs + setup costs + variable costs
obj                      Objective function

* ## Auxiliary functions ##
*auxstartup               auxiliary function to compute start-up costs (R&D and Engineering)
aux_var_costs(y)           auxiliary function to compute annual variable costs
*auxfixed_manuf          auxiliary function to compute fixed investment costs of manufacturing
auxvar_manuf(y)            auxiliary function to compute variable costs of manufacturing
auxvar_transp(y)           auxiliary function to compute variable costs of transportation
auxvar_store(y)            auxiliary function to compute variable costs of storage
;

*############ Not valid relations

         Flow.fx(lo,ld,m,trm,t,y)$(not networkConnected(trm,m,lo,ld))=0;
         Flow.fx(l,l,m,trm,t,y)=0;
         NrTrips.fx(trm,lo,ld,t,y)$(not flowAllConnections(trm,lo,ld))=0;
         NrTrips.fx(trm,l,l,t,y)=0;
         MatOrder.fx(l,l,m,t,y)=0;
         TrucksMonth.fx(trm,l,t,y)$(not t_truck(trm))=0;

* #################################################################################################################################################

* ### Production ###
*         eq1(sup,l,mat,t,y)$(pSupply(mat,sup))..         sum(f, sum(p$product(p), pBOM(mat,p)*scaleUpMult*Production(f,p,t,y))) =L= (lot_size(mat)*MatOrder(sup,l,mat,t,y) + StockLevel(l,mat,t,y));
*         eq2(sup,mat,t,y)..                              sum(l, (sum(trm$(networkConnected(trm,mat,sup,l) and noMatTransp(trm,mat)), Flow(sup,l,mat,trm,t,y))))
*                                                                 =E= sum(l, nominalWeight(mat)*lot_size(mat)*MatOrder(sup,l,mat,t,y));
*         eq3(sup,t,y)..                                  sum((mat,l), MatOrder(sup,l,mat,t,y)) =L= sup_capacity(sup)*Source(sup,t,y);
*         eq4(sup,t,y)..                                  sum((mat,l), MatOrder(sup,l,mat,t,y)) =G= sup_minimum(sup)*Source(sup,t,y);
*         eq5(j,t,y)..                                    sum(lo, sum(p$product(p), sum(trm$networkConnected(trm,p,lo,j), Flow(lo,j,p,trm,t,y)))) =G= demand(j,t);
*         eq6(f,p,t,y)$product(p)..                       Production(f,p,t,y)*(1-rej_rate) =G= sum(ld, sum(trm$networkConnected(trm,p,f,ld), Flow(f,ld,p,trm,t,y)));

*         eq7(f,p)$product(p)..                           sum((t,y), Production(f,p,t,y)) =L= (Forming(p)*bigM);
*         eq7a(f,ld,trm,p)$product(p)..                   sum((t,y), Flow(f,ld,p,trm,t,y)) =L= (Forming(p)*bigM);

*         eq10..                                          sum(p$product(p), Forming(p)) =E= 1;
*         eq11(p,f,r,t,y)$product(p)..                    sum((a), pBOT(r,p,a)*pTOP(a,p)*pScaleUp(a,p)*(1/pNBatch(a,p))*Production(f,p,t,y))
*                                                                 =L= res_prod(r)*(1/2)*Manuf_NrResource(r,t,y)*(hours_shift*shifts_day*day_month);
*##########
         eq5(ld,t,y)..                         sum(p$product(p), sum(lo$flowINcustFP(p,lo,ld), sum(trm$networkConnected(trm,p,lo,ld), Flow(lo,ld,p,trm,t,y)))) =E= demand(ld,t);
         eq7a(f,p)$product(p)..                sum((t,y), Production(f,p,t,y)) =L= (Forming(p)*bigM);
         eq7b(l,p)$product(p)..                sum((t,y), StockLevel(l,p,t,y)) =L= (Forming(p)*bigM);
         eq7c(f,ld,trm,p)$product(p)..         sum((t,y), Flow(f,ld,p,trm,t,y)) =L= (Forming(p)*bigM);

         eq10..                                          sum(p$product(p), Forming(p)) =L= 1;
         eq11(f,p,r,t,y)$product(p)..                    sum((a), pBOT(r,p,a)*pTOP(a,p)*pScaleUp(a,p)*(1/pNBatch(a,p))*Production(f,p,t,y))
                                                                 =L= res_prod(r)*(1/3)*Manuf_NrResource(r,t,y)*(hours_shift*shifts_day*day_month);


*Balance at warehouses
         eq12a(m,w,t,y)$(tFirst(t,y))..
                         pInitStock(m,w)$tFirst(t,y) + sum((lo)$(flowINwhFP(m,lo,w) or flowINwhRM(m,lo,w)), sum(trm$networkConnected(trm,m,lo,w), Flow(lo,w,m,trm,t,y)))
                                 =E= StockLevel(w,m,t,y) + sum((ld)$(flowOUTwhFP(m,w,ld) or flowOUTwhRM(m,w,ld)), sum(trm$networkConnected(trm,m,w,ld), Flow(w,ld,m,trm,t,y)));
         eq12b(m,w,t,y)$(tOther(t,y))..
                         StockLevel(w,m,t-1,y)$tOther(t,y) + sum((lo)$(flowINwhFP(m,lo,w) or flowINwhRM(m,lo,w)), sum(trm$networkConnected(trm,m,lo,w), Flow(lo,w,m,trm,t,y)))
                                 =E= StockLevel(w,m,t,y) + sum((ld)$(flowOUTwhFP(m,w,ld) or flowOUTwhRM(m,w,ld)), sum(trm$networkConnected(trm,m,w,ld), Flow(w,ld,m,trm,t,y)));
         eq12c(w,y)..      sum((m,t), StockLevel(w,m,t,y)) =L= maxWhCapacity(w)*Open(w);
         eq12d(w,y)..      sum((m,t), StockLevel(w,m,t,y)) =G= minWhCapacity(w)*Open(w);

*Material balance at the factories - Final Product:
          eEQ1(p,l,t,y)$(tFirst(t,y))..        pInitStock(p,l)$tFirst(t,y) + Production(l,p,t,y)
                                                         =E= StockLevel(l,p,t,y) + sum((ld)$(flowOUTfactFP(p,l,ld)), sum(trm$networkConnected(trm,p,l,ld), Flow(l,ld,p,trm,t,y)));

          eEQ1a(p,l,t,y)$(tOther(t,y))..       StockLevel(l,p,t-1,y)$tOther(t,y) + Production(l,p,t,y)
                                                         =E= StockLevel(l,p,t,y) + sum((ld)$(flowOUTfactFP(p,l,ld)), sum(trm$networkConnected(trm,p,l,ld), Flow(l,ld,p,trm,t,y)));

*Material balance at the factories - Raw Materials:
          eEQ2(mat,l,t,y)$(tFirst(t,y))..        pInitStock(mat,l)$tFirst(t,y) + sum(lo$flowINfactRM(mat,lo,l), sum(trm$networkConnected(trm,mat,lo,l), Flow(lo,l,mat,trm,t,y)))
                                                         =E= StockLevel(l,mat,t,y) + sum((p)$product(p), pBOM(mat,p)*scaleUpMult*Production(l,p,t,y));

          eEQ2a(mat,l,t,y)$(tOther(t,y))..       StockLevel(l,mat,t-1,y)$tOther(t,y) + sum(lo$flowINfactRM(mat,lo,l), sum(trm$networkConnected(trm,mat,lo,l), Flow(lo,l,mat,trm,t,y)))
                                                         =E= StockLevel(l,mat,t,y) + sum((p)$product(p), pBOM(mat,p)*scaleUpMult*Production(l,p,t,y));


*          eEQ2(m,l,t,y)..                          sum((trm,lo)$(flowINfactRM(m,lo,l) and networkConnected(trm,m,lo,l)), Flow(lo,l,m,trm,t,y))
*                                                                         =E= sum((mm,p)$product(p), pBOM(mm,p)*scaleUpMult*Production(l,p,t,y));

          eEQ3(m,lo,ld,t,y)$(pSupply(m,lo) and flowOUTsupRM(m,lo,ld))..  sum(trm$networkConnected(trm,m,lo,ld), Flow(lo,ld,m,trm,t,y))
                                                                                 =E= lot_size(m)*MatOrder(lo,ld,m,t,y);

** Flow if Open - all facilities
*         eEQ36(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     sum(m, Flow(lo,ld,m,trm,t,y)) =L= BigM*Open(lo);
*         eEQ37(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     sum(m, Flow(lo,ld,m,trm,t,y)) =L= BigM*Open(ld);

*        ### TRANSPORTATION ###
*Transportation physical constraints:
*         eEQ22(m,l,t,y)$(noAirFP(m,l) or noAirRM(m,l))..
*                         sum((trm,lo)$(networkConnected(trm,m,lo,l) and not(air(lo))), Flow(lo,l,m,trm,t,y))
*                                 =E= sum((trm,ld)$(networkConnected(trm,m,l,ld) and air(ld)), Flow(l,ld,m,trm,t,y));
*         eEQ23(m,l,t,y)$(noPortFP(m,l) or noPortRM(m,l))..
*                         sum((trm,lo)$(networkConnected(trm,m,lo,l) and not(port(lo))), Flow(lo,l,m,trm,t,y))
*                                 =E= sum((trm,ld)$(networkConnected(trm,m,l,ld) and port(ld)), Flow(l,ld,m,trm,t,y));

*Cross-docking at the airports:
*         e13(m,air,t,y)$(noAirFP(m,air) or noAirRM(m,air))..
*                         sum((mm,lo)$(flowINairFP(mm,lo,air) or flowINairRM(mm,lo,air)), sum(trm$networkConnected(trm,mm,lo,air), Flow(lo,air,mm,trm,t,y)))
*                         =E= sum((mm,ld)$(flowOUTairFP(mm,air,ld) or flowOUTairRM(mm,air,ld)), sum(trm$networkConnected(trm,mm,air,ld), Flow(air,ld,mm,trm,t,y)));
*Cross-docking at the seaports:
*         e14(m,port,t,y)$(noPortFP(m,port) or noPortRM(m,port))..
*                         sum((mm,lo)$(flowINportFP(mm,lo,port) or flowINportRM(mm,lo,port)), sum(trm$networkConnected(trm,mm,lo,port), Flow(lo,port,mm,trm,t,y)))
*                         =E= sum((mm,ld)$(flowOUTportFP(mm,port,ld) or flowOUTportRM(mm,port,ld)), sum(trm$networkConnected(trm,mm,port,ld), Flow(port,ld,mm,trm,t,y)));

*Cross-docking at the airports:
         e13(m,air,t,y)$(noAirFP(m,air) or noAirRM(m,air))..
                         sum((lo)$(flowINairFP(m,lo,air) or flowINairRM(m,lo,air)), sum(trm$networkConnected(trm,m,lo,air), Flow(lo,air,m,trm,t,y)))
                         =E= sum((ld)$(flowOUTairFP(m,air,ld) or flowOUTairRM(m,air,ld)), sum(trm$networkConnected(trm,m,air,ld), Flow(air,ld,m,trm,t,y)));
*Cross-docking at the seaports:
         e14(m,port,t,y)$(noPortFP(m,port) or noPortRM(m,port))..
                         sum((lo)$(flowINportFP(m,lo,port) or flowINportRM(m,lo,port)), sum(trm$networkConnected(trm,m,lo,port), Flow(lo,port,m,trm,t,y)))
                         =E= sum((ld)$(flowOUTportFP(m,port,ld) or flowOUTportRM(m,port,ld)), sum(trm$networkConnected(trm,m,port,ld), Flow(port,ld,m,trm,t,y)));


*Necessary number of trips:
          eEQ24a(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..    pTranspCapMat(trm)*NrTrips(trm,lo,ld,t,y)
                                                                         =G= sum(mat$(networkConnected(trm,mat,lo,ld)), nominalWeight(mat)*Flow(lo,ld,mat,trm,t,y));
          eEQ24b(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..    pTranspCapProd(trm)*NrTrips(trm,lo,ld,t,y)
                                                                         =G= sum(p$(networkConnected(trm,p,lo,ld)), nominalWeight(p)*Flow(lo,ld,p,trm,t,y));
          eEQ25(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     pCapMin(trm)*NrTrips(trm,lo,ld,t,y)
                                                                         =L= sum(m$(networkConnected(trm,m,lo,ld)), Flow(lo,ld,m,trm,t,y));
          eEQ26(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     NrTrips(trm,lo,ld,t,y) =L= BigM*Open(lo);
          eEQ27(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     NrTrips(trm,lo,ld,t,y) =L= BigM*Open(ld);


*Limits contracted capacity with air and sea carrier:
          eEQ28(trm,lo,ld,y)$(flowOnlyPlane(trm,lo,ld) or flowOnlyBoat(trm,lo,ld))..   sum(t, NrTrips(trm,lo,ld,t,y))
                                                                                                 =L= pCarrierMaxContract(trm);

*Necessary number of trucks:
          eEQ29(t_truck,lo,t,y)..                         TrucksMonth(t_truck,lo,t,y) =E= sum(ld$(flowOnlyTruck(t_truck,lo,ld)), dist(lo,ld)* NrTrips(t_truck,lo,ld,t,y)*2)/(pAVS*pMaxDriveHoursperWeek*pWeeksperTimePeriod);
          eEQ30(t_truckOWN,lo,t,y)..                      Trucks(t_truckOWN,lo) =G= TrucksMonth(t_truckOWN,lo,t,y);
          eEQ31(t,y)..                                    sum((t_truckOWN,lo), pTranspAcquire(t_truckOWN)*Trucks(t_truckOWN,lo)) =L= pMaxTruckInv;
          eEQ32(t_truckOWN,lo,y)..                        Trucks(t_truckOWN,lo) =L= BigM*Open(lo);
*?          eEQ33(t_truck,lo,y)..                           Trucks(t_truck,lo) =L= sum((t), sum((m,ld)$(networkConnected(t_truck,m,lo,ld)), nominalWeight(m)*Flow(lo,ld,m,t_truck,t,y)));


*############ ECONOMIC DIMENSION - NPV #############
          eNPV..         vNPV                               =E= (sum(y, vCashFlow(y)/((1+discountRate)**ord(y))) - vFixedCapInvTotal);
            eCF(y)$(not yLast(y))..     vCashFlow(y)$(not yLast(y))        =E= vNetEarn(y);
            eCFlast(y)$(yLast(y))..     vCashFlow(y)$(yLast(y))            =E= vNetEarn(y) + sum(gama, pSalvage(gama)*vFixedCapInvest(gama));
          eNE(y)..       vNetEarn(y)                        =E= (1-taxRate)*(revenueAnnual(y) - varAnnualCosts(y)) + taxRate*vDepCap(y);

          eFCIfac..      vFixedCapInvest('fac')             =E= sum(l$(f(l) or w(l)), (fixed_facility(l)+fixed_other(l))*Open(l));
          eFCIequip..    vFixedCapInvest('equip')           =E= sum((tech,p,l,t,y)$(f(l)), fixed_equip(tech)*Manuf_NrResource(tech,t,y) + fixed_tooling(p)*Forming(p));
          eFCItrucks..   vFixedCapInvest('tru')             =E= sum((trm,lo)$t_truck(trm), pTranspAcquire(trm)*Trucks(trm,lo));

          eDP(y)..       vDepCap(y)                         =E= sum(gama, pDepreciationRate(gama,y)*vFixedCapInvest(gama));
          eFCItotal..    vFixedCapInvTotal                  =E= sum(gama, vFixedCapInvest(gama));

aux_var_costs(y)..        varAnnualCosts(y)  =E= (manuf_var_cost(y) + transp_var_cost(y) + store_var_cost(y));

*auxfixed_manuf..         manuf_fixed_cost =E= sum((f,r,p), ((fixed_facility(f)*SW1) + (fixed_equip(r)*SW2) + (fixed_tooling(p)*SW3) + (fixed_other(f)*SW4))*Forming(p));
auxvar_manuf(y)..         manuf_var_cost(y) =E= sum((t), sum((ld,mat,sup), mCost(mat,sup)*MatOrder(sup,ld,mat,t,y)) + sum((r), rate_resource(r)*Manuf_NrResource(r,t,y)*(hours_shift*shifts_day*day_month)));

auxvar_transp(y)..        transp_var_cost(y) =E= sum((lo,ld,m,trm,t), sum((mtp), (pHubVarCost(mtp)*(Flow(mtp,ld,m,trm,t,y) + Flow(lo,mtp,m,trm,t,y))) + (pTripRate(trm) + dist(lo,ld)*pVarTranspCost(trm))*NrTrips(trm,lo,ld,t,y) + pAnnualContract(trm)*TranspUsed(trm)));

auxvar_store(y)..         store_var_cost(y) =E= sum((w,m,t), holding_cost(m)*StockLevel(w,m,t,y));

*obj..                     Z =E= vNPV;


*############ ENVIRONMENTAL DIMENSION #############

set       beta midpoint impact categories / CC /;
parameter pTranspImpact(trm,beta)          Characterization factor (per km) for environmental impact of transport mode trm in midpoint category beta
          pProductionImpact(beta,r,m)    Characterization factor (per kg) for environmental impact of production of product m through resource r in midpoint category beta
*          pEntityImpact(l,beta)            Characterization factor (per m2) for environmental impact of entity i
*          pEntImpFactory(beta)           Characterization factor (per m2) for environmental impact of factories
          pEntImpWarehouse(beta)         Characterization factor (per m2) for environmental impact of warehouses / CC 377.914722089478/
          pNormFactor(beta)              Normalization factor for each midpoint category / CC 0.000180718679514632 /
          ;

Table     pTranspImpact(trm,beta)            Initial stock of product m at entity i
                    CC
truck_own           0.000180718679514632
truck_out           0.000433701509416171
truckCOOL_own       0.00180718679514632
truckCOOL_out       0.00433701509416171
truck_XL_own        0.000180718679514632
truck_XL_out        0.000433701509416171
truckCOOL_XL_own    0.00180718679514632
truckCOOL_XL_out    0.00433701509416171
plane               0.00102593412851898
planeCOOL           0.0102593412851898
boat                0.0000108898952362431
boatCOOL            0.000108898952362431
rail                100
railCOOL            100
;

Table     pProductionEnergy(beta,r,m)            Production energy (kWh)
                 p1              p2              p3              p4
CC.o1            16.2            16.2            16.2            16.2
CC.o2            2.88            2.88            2.88            2.88
CC.o3            3               3               3               3
CC.o4            1               1               1               1
CC.l1            0               0               0               0
;

Table    mFootprint(beta,m,sup)    Material environmental footprint m from supplier i   (CO2 eq.)
         i1               i2              i3      i4
CC.rm1   12.09546673      10000           40      20
CC.rm2   8.551880762      10000           56.1    38.3
CC.rm3   1.867588935      10000           81.3    75.9
CC.rm4   9.644305053      10000           61.5    72.4
CC.rm5   10000            15.65018441     35.3    30.6
CC.sp1   15               10000           10      13
CC.sp2   1.25             10000           1.30    2
;

*display pProductionEnergy, pTranspImpact, pNormFactor;

variable vTranspImpact(trm,beta)         Environmental impact of transport mode a in midpoint category beta
         vProductionImpact(m,r,beta)     Environmental impact of production of product m with technology g in midpoint category beta
         vMatImpact(beta)                Environmental impact of materials bought
         vHoldingImpact(beta)
         vEntityImpact(beta)             Environmental impact of entity installation per midpoint category beta
         vEnvImpactPerCategory(beta)     Total environmental impact per midpoint category beta
         vEnvImpact                      Total environmental impact (normalized)
         ;
         vProductionImpact.fx(m,r,beta)$(not p(m))=0;

equation eTranspImpact(trm,beta)           Environmental impact of transportation mode a per midpoint category beta
         eProductionImpact(m,r,beta)     Environmental impact of production of product m with technology g per midpoint category beta
         eMatImpact(beta)                Environmental impact of materials bought
         eEnvHolding(beta)               Environmental impact of MTP
         eEntityImpact(beta)             Environmental impact of entity installation per midpoint category beta
         eEnvImpactPerCategory(beta)     Total environmental impact per midpoint category beta
         eEnvImpact                     Total environmental impact (normalized) per scenario
         ;
         eTranspImpact(trm,beta)..               vTranspImpact(trm,beta)      =E= sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and t_truck(trm)), pTranspImpact(trm,beta)*dist(lo,ld)*(1 + 1*pProductWeight(m)*Flow(lo,ld,m,trm,t,y)))
                                                                                 +sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and (t_plane(trm) or t_boat(trm))), pTranspImpact(trm,beta)*pProductWeight(m)*dist(lo,ld)*Flow(lo,ld,m,trm,t,y));
         eProductionImpact(p,r,beta)..           vProductionImpact(p,r,beta)     =E= sum((f,t,y), convertKWH_CO2*(pProductionEnergy(beta,r,p)*Production(f,p,t,y)));
         eMatImpact(beta)..                      vMatImpact(beta)                =E= sum((sup,ld,m,t,y), mFootprint(beta,m,sup)*MatOrder(sup,ld,m,t,y));
         eEntityImpact(beta)..                   vEntityImpact(beta)             =E= sum(w, pEntImpWarehouse(beta)*Open(w));
         eEnvHolding(beta)..                     vHoldingImpact(beta)            =E= sum((l,m,t,y), holding_impact(m)*StockLevel(l,m,t,y));
         eEnvImpactPerCategory(beta)..           vEnvImpactPerCategory(beta)     =E= sum(trm, vTranspImpact(trm,beta)) + sum((p,r), vProductionImpact(p,r,beta)) + vEntityImpact(beta) + vMatImpact(beta) + vHoldingImpact(beta);
         eEnvImpact..                            vEnvImpact                      =E= sum(beta, pNormFactor(beta)*vEnvImpactPerCategory(beta));

obj..                     Z =E= vEnvImpact;



*############ SOCIAL DIMENSION #############

set       alpha social impact categories / alpha1 /;
parameter pTranspSocImpact(trm,alpha)          Characterization factor (per km) for environmental impact of transport mode trm in midpoint category alpha
          pManufSocImpact(alpha,m)    Characterization factor (per kg) for environmental impact of production of product m through resource r in midpoint category alpha
*          pEntityImpact(l,beta)            Characterization factor (per m2) for environmental impact of entity i
*          pEntImpFactory(beta)           Characterization factor (per m2) for environmental impact of factories
         ;

Table     pTranspSocImpact(trm,alpha)
                 alpha1
truck_own        1
truck_out        1
truckCOOL_own    1
truckCOOL_out    1
plane            1
planeCOOL        1
boat             1
boatCOOL         1
rail             100
railCOOL         100
;

Table     pManufSocImpact(alpha,m)            Social impact of production
                 p1     p2      p3      p4
alpha1           10     10      3       2
;

variable vTranspSocImpact(trm,alpha)           Social impact of transport mode trm in category alpha
         vManufSocImpact(m,alpha)     Social impact of production of product m in category alpha
         vSocImpactPerCategory(alpha)     Total social impact per category alpha
         vSocImpact                      Total social impact
         ;
*         vSocImpact.fx(m,alpha)$(not p(m))=0;

equation eTranspSocImpact(trm,alpha)           Social impact of transportation mode trm per category alpha
         eManufSocImpact(m,alpha)        Social impact of production of product m per category alpha
         eSocImpactPerCategory(alpha)     Total social impact per category alpha
         eSocImpact                     Total social impact
         ;
*         eTranspSocImpact(trm,alpha)..               vTranspSocImpact(trm,alpha)      =E= sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and t_truck(trm)), pTranspSocImpact(trm,alpha)*dist(lo,lo)*(1 + 1*pProductWeight(m)*Flow(lo,ld,m,trm,t,y)))
*                                                                                 +sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and (t_plane(trm) or t_boat(trm))), pTranspSocImpact(trm,alpha)*pProductWeight(m)*dist(lo,ld)*Flow(lo,ld,m,trm,t,y));
         eTranspSocImpact(trm,alpha)..               vTranspSocImpact(trm,alpha)      =E= sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and t_truck(trm)), pTranspSocImpact(trm,alpha)*Flow(lo,ld,m,trm,t,y))
                                                                                 +sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and (t_plane(trm) or t_boat(trm))), pTranspSocImpact(trm,alpha)*Flow(lo,ld,m,trm,t,y));
         eManufSocImpact(p,alpha)..           vManufSocImpact(p,alpha)     =E= sum((f,t,y), pManufSocImpact(alpha,p)*Production(f,p,t,y));
         eSocImpactPerCategory(alpha)..           vSocImpactPerCategory(alpha)     =E= sum(trm, vTranspSocImpact(trm,alpha)) + sum(p, vManufSocImpact(p,alpha));
         eSocImpact..                            vSocImpact     =E= sum(alpha, vSocImpactPerCategory(alpha));

*obj..                     Z =E= vSocImpact;


model aero_model /all/;

aero_model.dictfile=0;
aero_model.optfile=1;
aero_model.holdfixed=1;
aero_model.optcr=0.01;


solve aero_model using MIP minimizing z;
*solve aero_model using MIP maximizing z
display z.L;
display Production.L, Flow.L, Forming.L, MatOrder.L, StockLevel.L, NrTrips.L, Trucks.L, TrucksMonth.L, vFixedCapInvest.L, vCashFlow.L, Manuf_NrResource.L, manuf_var_cost.L, transp_var_cost.L, store_var_cost.L, vNPV.L;