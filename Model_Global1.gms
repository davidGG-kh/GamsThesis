$ontext
Thesis - Model Global
27-JUN-2018 || Joao Felicio

### Model
### Uses data from Afonso 2017
$offtext

option MIP=cplex;
option iterlim = 900000000;
option reslim = 1728000000;
option solvelink=0;
*option optcr=0.1;
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
         set z           loop objective functions      / z1 /;
         alias(l,lo,ld);
         alias(z,zz);

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
         set t_truckOUT(trm)  / truck_out, truckCOOL_out, truck_XL_out, truckCOOL_XL_out /
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
         set lab(r)    labour                      / l1 /
;

set      y Tempo macro /y1*y15/;
         set yFirst(y)   first time period
             yOther(y)   all but first time period
             yLast(y)    final time period;
         yFirst(y)  = yes$(ord(y) eq 1);
         yOther(y)  = not yFirst(y);
         yLast(y)   = yes$(ord(y) eq card(y));
$ontext
set      t Tempo micro /t1*t12/;
         set tFirst(t,y)   first time period
             tOther(t,y)   all but first time period
             tLast(t,y)    final time period;
         tFirst(t,y)  = yes$(ord(t) eq 1);
         tOther(t,y)  = not tFirst(t,y);
         tLast(t,y)   = yes$(ord(t) eq card(t));
$offtext
set      t Tempo micro /t1*t12/;
         set tFirst(t,y)   first time period
             tOther(t,y)   all but first time period
             tLast(t,y)    final time period;
         tFirst(t,y)  = yes$((ord(t) eq 1) and (ord(y) eq 1));
         tOther(t,y)  = not tFirst(t,y);
         tLast(t,y)   = yes$((ord(t) eq card(t)) and (ord(y) eq card(y)));

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

* ############################ Constraints on sets (Mota et al., 2017) ###############################

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
         arcEUR_USA(lo,ld)       =yes$(Europe(lo)  and USA(ld));
         arcEUR_BRA(lo,ld)       =yes$(Europe(lo)  and Brasil(ld));
         arcInterCont(lo,ld)     =arcUSA_EUR(lo,ld)+arcUSA_BRA(lo,ld)+arcBRA_EUR(lo,ld)+arcBRA_USA(lo,ld)+arcEUR_USA(lo,ld)+arcEUR_BRA(lo,ld);
         arcEUR_EUR(lo,ld)       =yes$(Europe(lo) and Europe(ld));
         arcUSA_USA(lo,ld)       =yes$(USA(lo) and USA(ld));
         arcBRA_BRA(lo,ld)       =yes$(Brasil(lo) and Brasil(ld));
         arcIntraCont(lo,ld)     =yes$(arcEUR_EUR(lo,ld) + arcUSA_USA(lo,ld) + arcBRA_BRA(lo,ld));
         arcAll(lo,ld)           =arcSupFact(lo,ld)+arcSupWh(lo,ld)+arcSupAir(lo,ld)+arcSupPort(lo,ld)+arcFactWh(lo,ld)+arcFactAir(lo,ld)
                                 +arcFactPort(lo,ld)+arcFactCust(lo,ld)+arcWhFact(lo,ld)+arcWhWh(lo,ld)+arcWhAir(lo,ld)+arcWhPort(lo,ld)
                                 +arcWhCust(lo,ld)+arcAirFact(lo,ld)+arcAirWh(lo,ld)+arcAirAir(lo,ld)+arcAirPort(lo,ld)+arcAirCust(lo,ld)
                                 +arcPortFact(lo,ld)+arcPortWh(lo,ld)+arcPortAir(lo,ld)+arcPortPort(lo,ld)+arcPortCust(lo,ld);
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

Table     pInitRes(r,l)            Initial resources r at entity i
         f1
o1       0
o2       0
o3       0
o4       0
l1       0
;

Table     pInitFleet(trm,l)            Initial resources r at entity i
                         i1      i2      i3      i4      w1      w2      w3      f1      j1
truck_own                0       0       0       0       0       0       0       0       0
truckCOOL_own            0       0       0       0       0       0       0       0       0
truck_XL_own             0       0       0       0       0       0       0       0       0
truckCOOL_XL_own         0       0       0       0       0       0       0       0       0
;

Scalar
rej_rate                 Part rejection rate                             / .10 /
hours_shift              Hours per shift                                 / 8 /
shifts_day               Shifts per day                                  / 1 /
day_month                Avg. Days per month                             / 21 /
bigM                     Big value                                       / 150000 /
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

Parameters
sup_capacity(l)          Capacity of Supplier i                  / i1 100000, i2 100000, i3 100000, i4 100000 /
sup_minimum(l)           Minimum quantity of Supplier i          / i1 1, i2 1, i3 1, i4 1 /
plant_capacity(l)        Capacity of plant f                     / f1 2244984 /
maxWhCapacity(w)                                                 / w1 10000, w2 10000, w3 10000 /
minWhCapacity(w)                                                 / w1 1, w2 1, w3 1 /
lot_size(m)              Lot size of material m                  / rm1 764.1, rm2 492.5, rm3 230, rm4 728.6, rm5 624, sp1 50, sp2 50 /
*MOQ(m)                   Minimum order quantity (in kgs) - to put in units         / rm1 764.1, rm2 492.5, rm3 230, rm4 728.6, rm5 624, sp1 10, sp2 10 /
res_prod(r)              Resource productivity                   / o1 0.9, o2 0.9, o3 0.9, o4 0.9, l1 0.78 /
holding_impact(m)        Env. impact of holding material m       / rm1 100, rm2 100, rm3 100, rm4 100, rm5 100, sp1 100, sp2 100, p1 100, p2 100, p3 100, p4 100 /
soc_holding_impact(m)        Soc. impact of holding material m   / rm1 100, rm2 100, rm3 100, rm4 100, rm5 100, sp1 100, sp2 100, p1 100, p2 100, p3 100, p4 100 /
nominalWeight(m)         Nominal weight m2 to kg                 / rm1 0.294, rm2 0.194, rm3 1, rm4 0.134, rm5 1, sp1 1, sp2 1, p1 1, p2 1, p3 1, p4 1 /
product(p)               Products allowed                        / p1 1, p2 1, p3 1, p4 0 /
;

Table    demand(l,t)     Monthly Demand of aircraft parts for Integrator j
         t1      t2      t3      t4      t5      t6      t7      t8      t9      t10     t11     t12
j1       17      17      17      17      17      17      17      17      17      17      17      17
;

$ontext
Table    pBOM(m,p)       BOM for product p in quantity
        p1       p2      p3      p4
rm1     739.4    0       0       0
rm2     0        485.9   0       0
rm3     0        218.2   0       0
rm4     0        0       716.0   0
rm5     0        0       0       617.8
sp1     0.5      0.5     0.5     0.5
sp2     1.5      1.5     1.5     1.5
;
$offtext
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

Table    pScaleUp(a,p)   Scale-up Relation
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

* ### Product characterization ###


parameter        pProductWeight(m)       Weight of product p
                 / p1 568.8
                 p2 541.6
                 p3 550.8
                 p4 475.2 /
                 mAreaUnit(m)            Necessary area per material unit
                 / rm1 0.002
                 rm2 0.001
                 rm3 0.004
                 rm4 0.003
                 rm5 0.007
                 sp2 0.009
                 sp1 0.007
                 p1 0.001
                 p2 0.001
                 p3 0.001
                 p4 0.001 /
;

* ### TRANSPORTATION MODES ###
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
          /truck_own 25000
           truck_out 25000
           truck_XL_own 40000
           truck_XL_out 40000
           plane  137750
           boat   49900000
           truckCOOL_own 25000
           truckCOOL_out 25000
           truckCOOL_XL_own 40000
           truckCOOL_XL_out 40000
           planeCOOL  137750
           boatCOOL   49900000/
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
          pTruckMaintenance(trm)
          /truck_own     1000
          truckCOOL_own  1500
          truck_XL_own     1500
          truckCOOL_XL_own  2000/
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

          pVarTranspCost(trm)       Transport cost for transportation mode a per kg.km

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
Flow(lo,ld,m,trm,t,y)            Flow of material m from l.origin to l.destination in period t (in units)
Production(l,p,t,y)              Production at plant f of product p in day d
MatOrder(lo,ld,m,t,y)            Order quantity of material m from supplier i to plant f in day d (in units)
Open(l)                          Equal to 1 if plant f is open
Forming(p)                       Forming scenario s is active
Manuf_NrResource(r,y)          Number of resources to hire for line f in period t
StockLevel(l,m,t,y)              Amount of material m stored in facility w in day d
Source(sup,t,y)                  Supplier sup is used
NrTrips(trm,lo,ld,t,y)           Number of trips with transportation mode trm between entity lo and entity ld in time period (dt)
TrucksMonth(trm,l,t,y)           Number of transportation modes trm necessary in entity lo in time period dt
Fleet(trm,l,y)                 Number of transportation modes trm necessary in entity lo in total
Cell(l,m,y)                      Number of storage cells open at warehouse l with material m
TranspUsed(trm)                  Transports used
HireResource(r,y)              Hire resource
FireResource(r,y)              Fire resource
BuyTruck(t_truckOWN,l,y)       Buy truck
SellTruck(t_truckOWN,l,y)      Sell truck

results(z)                       Results
* Objective function:
Objf(z) objective variable
objective   auxiliary objective function
;

positive variable Manuf_NrResource, Production, Flow, MatOrder, StockLevel;
positive variable NrTrips, TrucksMonth, Fleet;
binary variable Open, Source, Forming, TranspUsed;
positive variable Cell;
integer variable HireResource, FireResource, BuyTruck, SellTruck;
free variable Objf, objective;

Equations
*General
         eqA1(ld,t,y)             Demand
         eqA2(f,p)                 Activate forming scenarios with production
*         eqA3(l,p)
*         eqA4(f,ld,trm,p)           Activate forming scenarios with flow
         eqA5                     Scenarios
         eqA6(f,p,r,t,y)            Production capacity limited to resources
         eqA7(r,l,y)            Balance resources t=0
*         eqA8(r,l,y)            Balance resources t>0
*         eqA9(l,t,y)            Only flow if open - inbound
*         eqA10(l,t,y)           Only flow if open - inbound
*         eqA11(l,t,y)           Only flow if open - outbound
*         eqA12(l,t,y)           Only flow if open - outbound

*Balance at factories
         eqB1(p,l,t,y)
         eqB2(p,l,t,y)
         eqB3(mat,l,t,y)
         eqB4(mat,l,t,y)
         eqB5(m,lo,ld,t,y)

         eqB6(m,ld,t,y)
* Balance at warehouses
         eqC1(m,w,t,y)           Balance at warehouses - period 0
*         eqC2(m,w,t,y)           Balance at warehouses - other periods
*         eqC3(w,y)               stocklevel max
*         eqC4(w,y)               stocklevel min

*Necessary number of trips:
         eqD1(trm,lo,ld,t,y)  Necessary number of trips according to transport mode's maximum capacity for raw materials
         eqD2(trm,lo,ld,t,y)   Necessary number of trips according to transport mode's maximum capacity for finished products
         eqD3(trm,lo,ld,t,y)   Minimum cargo in each transport mode
         eqD4(trm,lo,ld,t,y)   Transp Used
         eqD5(trm,lo,ld,t,y)   Q only if Y
$ontext
*Balance of fleet
         eqD6(trm,l,y)         Balance of fleet
         eqD7(trm,l,y)        Balance of fleet

*Necessary number of transportation modes:
         eqD8(trm,l,t,y)       Necessary number of trucks in each time period
         eqD9(l,t,y)       Necessary number of trucks in each entity for all time horizon
         eqD10                  Maximum investment in road transportation
*         eqD11(trm,l,t,y)           K only if Y
*         eqD10(trm,l)            integer
$offtext
*Limits contracted capacity with air and sea carrier:
         eqE1(trm,lo,ld,y)   Maximum trips contracted with carrier per time period
         eqE2(trm,lo,ld,y)
*Cross-docking at airports
         eqF1(m,air,t,y)
*Cross-docking at seaports
         eqF2(m,port,t,y)
*AUX - BOUNDS
         eqAUX1(t_truckOWN,l,y)
         eQAUX2(t_truckOWN,l,y)
         eqAUX3(t_truckOWN,l,y)
         eqAUX4(t_truckOWN,l,y)
         eqAUX5(t_truckOWN,l,y)
         eqAUX6(t_truckOWN,l,y)
         eqAUX7(r,y)
         eqAUX8(r,y)
         eqAUX9(r,y)
         eqAUX10(r,y)
         eqAUX11(r,y)
         eqAUX12(r,y)
* objective function: economic, environmental or social
obj1                      Objective function
*obj2                      Objective function
*obj3                      Objective function
obj4
;

*############ Not valid relations #############################################################
         Flow.fx(lo,ld,m,trm,t,y)$(not networkConnected(trm,m,lo,ld))=0;
         Flow.fx(l,l,m,trm,t,y)=0;
         NrTrips.fx(trm,lo,ld,t,y)$(not flowAllConnections(trm,lo,ld))=0;
         NrTrips.fx(trm,l,l,t,y)=0;
         MatOrder.fx(l,l,m,t,y)=0;
         TrucksMonth.fx(trm,l,t,y)$(not t_truck(trm))=0;
         Fleet.fx(trm,l,y)$(not t_truckOWN(trm))=0;

* ############### EQUATIONS ############################################################################################################
*General
         eqA1(ld,t,y)..                        sum(p$product(p), sum(lo$flowINcustFP(p,lo,ld), sum(trm$networkConnected(trm,p,lo,ld), Flow(lo,ld,p,trm,t,y))))
                                                 =E= demand(ld,t);
         eqA2(f,p)$product(p)..                sum((t,y), Production(f,p,t,y)) =L= (Forming(p)*bigM);
*         eqA3(l,p)$product(p)..                sum((t,y), StockLevel(l,p,t,y)) =L= (Forming(p)*bigM);
*         eqA4(f,ld,trm,p)$product(p)..         sum((t,y), Flow(f,ld,p,trm,t,y)) =L= (Forming(p)*bigM);
         eqA5..                                sum(p$product(p), Forming(p)) =L= 1;
         eqA6(f,p,r,t,y)$product(p)..          sum((a), pBOT(r,p,a)*pTOP(a,p)*pScaleUp(a,p)*(1/pNBatch(a,p))*Production(f,p,t,y))
                                                 =L= res_prod(r)*(1/3)*Manuf_NrResource(r,y)*(hours_shift*shifts_day*day_month);
*Balance of workforce/resources
         eqA7(r,l,y)..        pInitRes(r,l)$yFirst(y) + Manuf_NrResource(r,y-1)$yOther(y) + HireResource(r,y) - FireResource(r,y)
                                                         =E= Manuf_NrResource(r,y);

*Generic Flow equations
*         eqA9(l,t,y)..                    sum((lo,m,trm), Flow(lo,l,m,trm,t,y)) =L= 1000000*Open(l);
*         eqA10(l,t,y)..                   sum((lo,m,trm), Flow(lo,l,m,trm,t,y)) =L= 1000000*Open(l);
*         eqA11(l,t,y)..                   sum((ld,m,trm), Flow(l,ld,m,trm,t,y)) =L= 1000000*Open(l);
*         eqA12(l,t,y)..                   sum((ld,m,trm), Flow(l,ld,m,trm,t,y)) =L= 1000000*Open(l);

*#Storage
*Material balance at the factories - Final Product:
         eqB1(p,l,t,y)$(tFirst(t,y))..        pInitStock(p,l)$tFirst(t,y) + Production(l,p,t,y)
                                                         =E= StockLevel(l,p,t,y) + sum((ld)$(flowOUTfactFP(p,l,ld)), sum(trm$networkConnected(trm,p,l,ld), Flow(l,ld,p,trm,t,y)));
         eqB2(p,l,t,y)$(tOther(t,y))..       StockLevel(l,p,t-1,y)$tOther(t,y) + Production(l,p,t,y)
                                                         =E= StockLevel(l,p,t,y) + sum((ld)$(flowOUTfactFP(p,l,ld)), sum(trm$networkConnected(trm,p,l,ld), Flow(l,ld,p,trm,t,y)));
*Material balance at the factories - Raw Materials:
         eqB3(mat,l,t,y)$(tFirst(t,y))..        pInitStock(mat,l)$tFirst(t,y) + sum(lo$flowINfactRM(mat,lo,l), sum(trm$networkConnected(trm,mat,lo,l), Flow(lo,l,mat,trm,t,y)))
                                                         =E= StockLevel(l,mat,t,y) + sum((p)$product(p), pBOM(mat,p)*scaleUpMult*Production(l,p,t,y));
         eqB4(mat,l,t,y)$(tOther(t,y))..       StockLevel(l,mat,t-1,y)$tOther(t,y) + sum(lo$flowINfactRM(mat,lo,l), sum(trm$networkConnected(trm,mat,lo,l), Flow(lo,l,mat,trm,t,y)))
                                                         =E= StockLevel(l,mat,t,y) + sum((p)$product(p), pBOM(mat,p)*scaleUpMult*Production(l,p,t,y));

         eqB5(m,lo,ld,t,y)$(pSupply(m,lo) and flowOUTsupRM(m,lo,ld))..  sum(trm$networkConnected(trm,m,lo,ld), Flow(lo,ld,m,trm,t,y))
                                                                         =E= lot_size(m)*MatOrder(lo,ld,m,t,y);

*Balance out of suppliers enters warehouses or factories
         eqB6(m,ld,t,y)..                sum((lo)$(flowOUTsupRM(m,lo,ld)), sum(trm$networkConnected(trm,m,lo,ld), Flow(lo,ld,m,trm,t,y)))
                                                              =E= sum((lo)$(flowINwhFP(m,lo,ld) or flowINwhRM(m,lo,ld)), sum(trm$networkConnected(trm,m,lo,ld), Flow(lo,ld,m,trm,t,y)))
                                                              + sum(lo$flowINfactRM(m,lo,ld), sum(trm$networkConnected(trm,m,lo,ld), Flow(lo,ld,m,trm,t,y)));
*Balance at warehouses
         eqC1(m,w,t,y)..
                         pInitStock(m,w)$tFirst(t,y) + StockLevel(w,m,t-1,y)$tOther(t,y) + sum((lo)$(flowINwhFP(m,lo,w) or flowINwhRM(m,lo,w)), sum(trm$networkConnected(trm,m,lo,w), Flow(lo,w,m,trm,t,y)))
                                 =E= StockLevel(w,m,t,y) + sum((ld)$(flowOUTwhFP(m,w,ld) or flowOUTwhRM(m,w,ld)), sum(trm$networkConnected(trm,m,w,ld), Flow(w,ld,m,trm,t,y)));

*         eqC3(w,y)..      sum((m,t), StockLevel(w,m,t,y)) =L= maxWhCapacity(w)*Open(w);
*         eqC4(w,y)..      sum((m,t), StockLevel(w,m,t,y)) =G= minWhCapacity(w)*Open(w);

*#Transportation
*Necessary number of trips:
         eqD1(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..    pTranspCapMat(trm)*NrTrips(trm,lo,ld,t,y)
                                                                         =G= sum(mat$(networkConnected(trm,mat,lo,ld)), nominalWeight(mat)*Flow(lo,ld,mat,trm,t,y));
         eqD2(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..    pTranspCapProd(trm)*NrTrips(trm,lo,ld,t,y)
                                                                         =G= sum(p$(networkConnected(trm,p,lo,ld)), nominalWeight(p)*Flow(lo,ld,p,trm,t,y));
         eqD3(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     pCapMin(trm)*NrTrips(trm,lo,ld,t,y)
                                                                         =L= sum(m$(networkConnected(trm,m,lo,ld)), Flow(lo,ld,m,trm,t,y));
         eqD4(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     NrTrips(trm,lo,ld,t,y) =L= 100000*Open(lo);
         eqD5(trm,lo,ld,t,y)$(flowAllConnections(trm,lo,ld))..     NrTrips(trm,lo,ld,t,y) =L= 100000*Open(ld);
$ontext
*Balance of fleet
         eqD6(t_truckOWN,l,y)$(yFirst(y))..        pInitFleet(t_truckOWN,l)$yFirst(y) + BuyTruck(t_truckOWN,l,y) - SellTruck(t_truckOWN,l,y)
                                                         =E= Fleet(t_truckOWN,l,y);
         eqD7(t_truckOWN,l,y)$(yOther(y))..        Fleet(t_truckOWN,l,y-1)$yOther(y) + BuyTruck(t_truckOWN,l,y) - SellTruck(t_truckOWN,l,y)
                                                         =E= Fleet(t_truckOWN,l,y);

         eqD8(t_truck,lo,t,y)..                         TrucksMonth(t_truck,lo,t,y) =E= sum(ld$(flowOnlyTruck(t_truck,lo,ld)),
                                                                 dist(lo,ld)* NrTrips(t_truck,lo,ld,t,y)*2)/(pAVS*pMaxDriveHoursperWeek*pWeeksperTimePeriod);
         eqD9(lo,t,y)..                                 sum(t_truckOWN, Fleet(t_truckOWN,lo,y)) =G= sum(t_truckOWN, TrucksMonth(t_truckOWN,lo,t,y));
         eqD10(y)..                                   sum((t_truckOWN,lo), pTranspAcquire(t_truckOWN)*BuyTruck(t_truckOWN,lo,y)) =L= pMaxTruckInv;

$offtext
*         eqD11(t_truckOWN,lo,t,y)..                     Fleet(t_truckOWN,lo,t,y) =L= 100*Open(lo);
*         eqD9(t_truck,lo,y)..                           Trucks(t_truck,lo) =L= 1500*Open(lo);

*?        eqD2(t_truck,lo,y)..                           Trucks(t_truck,lo) =L= sum((t), sum((m,ld)$(networkConnected(t_truck,m,lo,ld)), nominalWeight(m)*Flow(lo,ld,m,t_truck,t,y)));

*Limits contracted capacity with air and sea carrier:
         eqE1(trm,lo,ld,y)$(flowOnlyPlane(trm,lo,ld) or flowOnlyBoat(trm,lo,ld))..   sum(t, NrTrips(trm,lo,ld,t,y)) =L= pCarrierMaxContract(trm);

*Limits contracted capacity with outsourced trucking:
         eqE2(t_truckOUT,lo,ld,y)$(flowOnlyTruck(t_truckOUT,lo,ld))..   sum(t, NrTrips(t_truckOUT,lo,ld,t,y)) =L= pCarrierMaxContract(t_truckOUT);

*Cross-docking at the airports:
         eqF1(m,air,t,y)$(noAirFP(m,air) or noAirRM(m,air))..
                         sum((lo)$(flowINairFP(m,lo,air) or flowINairRM(m,lo,air)), sum(trm$networkConnected(trm,m,lo,air), Flow(lo,air,m,trm,t,y)))
                         =E= sum((ld)$(flowOUTairFP(m,air,ld) or flowOUTairRM(m,air,ld)), sum(trm$networkConnected(trm,m,air,ld), Flow(air,ld,m,trm,t,y)));
*Cross-docking at the seaports:
         eqF2(m,port,t,y)$(noPortFP(m,port) or noPortRM(m,port))..
                         sum((lo)$(flowINportFP(m,lo,port) or flowINportRM(m,lo,port)), sum(trm$networkConnected(trm,m,lo,port), Flow(lo,port,m,trm,t,y)))
                         =E= sum((ld)$(flowOUTportFP(m,port,ld) or flowOUTportRM(m,port,ld)), sum(trm$networkConnected(trm,m,port,ld), Flow(port,ld,m,trm,t,y)));

*AUX - BOUNDS
         eqAUX1(t_truckOWN,l,y)..      Fleet(t_truckOWN,l,y) =G= 0;
         eqAUX2(t_truckOWN,l,y)..      Fleet(t_truckOWN,l,y) =L= 10;
         eqAUX3(t_truckOWN,l,y)..      BuyTruck(t_truckOWN,l,y) =G= 0;
         eqAUX4(t_truckOWN,l,y)..      BuyTruck(t_truckOWN,l,y) =L= 10;
         eqAUX5(t_truckOWN,l,y)..      SellTruck(t_truckOWN,l,y) =G= 0;
         eqAUX6(t_truckOWN,l,y)..      SellTruck(t_truckOWN,l,y) =L= 10;
         eqAUX7(r,y)..                 Manuf_NrResource(r,y) =G=0;
         eqAUX8(r,y)..                 Manuf_NrResource(r,y) =L=10;
         eqAUX9(r,y)..                 HireResource(r,y) =G=0;
         eqAUX10(r,y)..                HireResource(r,y) =L=20;
         eqAUX11(r,y)..                FireResource(r,y) =G=0;
         eqAUX12(r,y)..                FireResource(r,y) =L=20;


parameter active(z);
*############ ECONOMIC DIMENSION - NPV #############

set      gamma investments /fac, equip, tru/;

Parameter

*        rate_resource(r)         Rate of resource r  (eur)               / o1 3157.146, o2 902.054, o3 4059.2, o4 225.492, l1 25.37 /
         rate_resource(r)         Rate of resource r                      / o1 70, o2 20, o3 90, o4 5, l1 25 /
         fixed_equip(r)           Fixed costs of equipment per r (eur)    / o1 2029600, o2 367682, o3 897143, o4 270888, l1 0 /
         fixed_facility(l)        Fixed costs of facility per f  (eur)    / f1 500000, w1 500000, w2 500000, w3 500000 /
         sqmc(l)                  Cost per installation of sq. meter  (eur)    / f1 318, w1 318, w2 600, w3 538 /
         fixed_tooling(p)         Fixed costs of tooling per p (eur)      / p1 2000000, p2 1000000, p3 2000000, p4 1000000 /
         fixed_other(l)           Other fixed costs per f                 / f1 50000 /
         revenueAnnual(y)         Revenue per year                        / y1 0, y2 0, y3 0, y4 0, y5 0, y6 0, y7 0, y8 0, y9 0, y10 0, y11 0, y12 0, y13 0, y14 0, y15 0 /
         holding_cost(m)          Holding cost of material m              / rm1 100000, rm2 100000, rm3 100000, rm4 100000, rm5 100000, sp1 100000, sp2 1000000, p1 1000000, p2 1000000, p3 1000000, p4 100000 /
*        holding_cost(m)          Holding cost of material m              / rm1 100, rm2 100, rm3 100, rm4 100, rm5 100, sp1 100, sp2 100, p1 100, p2 100, p3 100, p4 100 /
         hiringCost(r)           Hiring cost of res r                    / o1 2029600, o2 367682, o3 897143, o4 270888, l1 0 /
         firingCost(r)           Firing cost of res r                    / o1 0, o2 0, o3 0, o4 0, l1 10000 /
;

parameter pSalvage(gamma)  Salvage value for each investment at the end of the 15 years
                   /fac  0.55
                   equip 0
                   tru   0/
;

table     pDepreciationRate(gamma,y)     Depreciation rate at time period t of each type of investment gamma
         y1      y2      y3      y4      y5      y6      y7      y8      y9      y10     y11     y12     y13     y14     y15
fac      0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.05    0.01    0.01    0.01    0.01    0.01
equip    0.125   0.125   0.125   0.125   0.125   0.125   0.125   0.125   0       0       0       0       0       0       0
tru      0.2     0.2     0.2     0.2     0.2     0       0       0       0       0       0       0       0       0       0
;

Variables
vNPV                        Expected Profit
vCashFlow(y)                Cash Flow
vNetEarn(y)                 Net earnings
vDepCap(y)                  Depreciation of the capital in time period t
vFixedCapInvest(gamma)      Fixed capital investment of each investment gamma
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

Equations
        eNPV              Net Present Value
        eCF(y)            Cash flow
        eCFlast(y)        Cash flow in the final time period
        eNE(y)            Net earnings
        eDP(y)            Depreciation of the capital in time period t
        eFCIfac           Fixed capital investment in entities
        eFCIequip         Fixed capital investment in technologies
        eFCItrucks        Fixed capital investment in trucks
        eFCItotal         FCI total

* ## Auxiliary functions ##
        aux_var_costs(y)           auxiliary function to compute annual variable costs
        auxvar_manuf(y)            auxiliary function to compute variable costs of manufacturing
*        auxfixed_manuf
        auxvar_transp(y)           auxiliary function to compute variable costs of transportation
        auxvar_store(y)            auxiliary function to compute variable costs of storage
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

$ontext
Table    mCost(m,sup)    Cost of material m from supplier i (EUR)
        i1          i2          i3        i4
rm1     92648       1000000     94368     101248
rm2     174826      1000000     187248    176928
rm3     13193       1000000     15248     14425
rm4     164282      1000000     178648    204448
rm5     1000000     129411      153708    154568
sp1     15          1000000     10        13
sp2     1.25        1000000     1.30      2
;

Table    mCost(m,sup)    Cost of material m from supplier i (usd)
        i1          i2          i3        i4
rm1     107730      1000000     109730    117730
rm2     203286      1000000     217730    205730
rm3     15341       1000000     17730     16773
rm4     191025      1000000     207730    237730
rm5     1000000     150478      178730    179730
sp1     15          1000000     10        13
sp2     1.25        1000000     1.30      2
;
$offtext

          eNPV..         vNPV                               =E= (sum(y, vCashFlow(y)/((1+discountRate)**ord(y))) - vFixedCapInvTotal);
            eCF(y)$(not yLast(y))..     vCashFlow(y)$(not yLast(y))        =E= vNetEarn(y);
            eCFlast(y)$(yLast(y))..     vCashFlow(y)$(yLast(y))            =E= vNetEarn(y) + sum(gamma, pSalvage(gamma)*vFixedCapInvest(gamma));
          eNE(y)..       vNetEarn(y)                        =E= (1-taxRate)*(revenueAnnual(y) - varAnnualCosts(y)) + taxRate*vDepCap(y);

          eFCIfac..      vFixedCapInvest('fac')             =E= sum(l$(f(l) or w(l)), (fixed_facility(l)+fixed_other(l))*Open(l));
          eFCIequip..    vFixedCapInvest('equip')           =E= sum((tech,p,t,y), fixed_equip(tech)*HireResource(tech,y) + fixed_tooling(p)*Forming(p));
          eFCItrucks..   vFixedCapInvest('tru')             =E= sum((t_truckOWN,l,y), pTranspAcquire(t_truckOWN)*BuyTruck(t_truckOWN,l,y));

          eDP(y)..       vDepCap(y)                         =E= sum(gamma, pDepreciationRate(gamma,y)*vFixedCapInvest(gamma));
          eFCItotal..    vFixedCapInvTotal                  =E= sum(gamma, vFixedCapInvest(gamma));

aux_var_costs(y)..        varAnnualCosts(y)  =E= (manuf_var_cost(y) + transp_var_cost(y) + store_var_cost(y));

*auxfixed_manuf..          manuf_fixed_cost =E= sum((f,r,p), ((fixed_facility(f)) + (fixed_equip(r)) + (fixed_tooling(p)) + (fixed_other(f)))*Forming(p));
auxvar_manuf(y)..         manuf_var_cost(y) =E= sum((t), sum((ld,mat,sup), mCost(mat,sup)*MatOrder(sup,ld,mat,t,y))
                                 + sum((r), firingCost(r)*FireResource(r,y) + rate_resource(r)*Manuf_NrResource(r,y)*(hours_shift*shifts_day*day_month*12)));

auxvar_transp(y)..        transp_var_cost(y) =E= sum((lo,ld,m,trm,t), sum((mtp), pTruckMaintenance(trm)*Fleet(trm,lo,y)
                                 + (pHubVarCost(mtp)*(Flow(mtp,ld,m,trm,t,y) + Flow(lo,mtp,m,trm,t,y))) + (pTripRate(trm)
                                 + dist(lo,ld)*pVarTranspCost(trm))*NrTrips(trm,lo,ld,t,y) + pAnnualContract(trm)*TranspUsed(trm)));

auxvar_store(y)..         store_var_cost(y) =E= sum((l,m,t), holding_cost(m)*StockLevel(l,m,t,y));



*############ ENVIRONMENTAL DIMENSION #############

set       beta midpoint impact categories / CC, energy /;
parameter pTranspImpact(trm,beta)        Characterization factor (per km) for environmental impact of transport mode trm in midpoint category beta
          pProductionImpact(beta,r,m)    Characterization factor (per kg) for environmental impact of production of product m through resource r in midpoint category beta
*          pEntityImpact(l,beta)          Characterization factor (per m2) for environmental impact of entity i
*          pEntImpFactory(beta)           Characterization factor (per m2) for environmental impact of factories
          pEntImpWarehouse(beta)         Characterization factor (per m2) for environmental impact of warehouses / CC 377.914722089478/
          pNormFactor(beta)              Normalization factor for each midpoint category / CC 0.000180718679514632 /
          ;

Table     pTranspImpact(trm,beta)            Initial stock of product m at entity i
                    CC                      energy
truck_own           0.000180718679514632    0
truck_out           0.000433701509416171    0
truckCOOL_own       0.00180718679514632     0
truckCOOL_out       0.00433701509416171     0
truck_XL_own        0.000180718679514632    0
truck_XL_out        0.000433701509416171    0
truckCOOL_XL_own    0.00180718679514632     0
truckCOOL_XL_out    0.00433701509416171     0
plane               0.00102593412851898     0
planeCOOL           0.0102593412851898      0
boat                0.0000108898952362431   0
boatCOOL            0.000108898952362431    0
rail                100                     0
railCOOL            100                     0
;

Table     pProductionEnergy(beta,r,m)            Production energy (kWh)
                    p1              p2              p3              p4
CC.o1               0               0               0               0
CC.o2               0               0               0               0
CC.o3               0               0               0               0
CC.o4               0               0               0               0
CC.l1               0               0               0               0
energy.o1           16.2            16.2            16.2            16.2
energy.o2           2.88            2.88            2.88            2.88
energy.o3           3               3               3               3
energy.o4           1               1               1               1
energy.l1           0               0               0               0
;

Table    mFootprint(beta,m,sup)    Material environmental footprint m from supplier i   (CO2 eq. and kwh)
            i1         i2          i3      i4
CC.rm1      18.4       10000       40      20
CC.rm2      4.46       10000       56.1    38.3
CC.rm3      11.34      10000       81.3    75.9
CC.rm4      13.3       10000       61.5    72.4
CC.rm5      10000      17.3        35.3    30.6
CC.sp1      15         10000       10      13
CC.sp2      1.25       10000       1.30    2
energy.rm1  34.3       10000       40      50
energy.rm2  8.3        10000       56.1    38.3
energy.rm3  21.11      10000       81.3    75.9
energy.rm4  24.8       10000       61.5    72.4
energy.rm5  10000      32.22        35.3    30.6
energy.sp1  15         10000       10      13
energy.sp2  1.25       10000       1.30    2

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

equation eTranspImpact(trm,beta)         Environmental impact of transportation mode a per midpoint category beta
         eProductionImpact(m,r,beta)     Environmental impact of production of product m with technology g per midpoint category beta
         eMatImpact(beta)                Environmental impact of materials bought
         eEnvHolding(beta)               Environmental impact of MTP
         eEntityImpact(beta)             Environmental impact of entity installation per midpoint category beta
         eEnvImpactPerCategory(beta)     Total environmental impact per midpoint category beta
         eEnvImpact                      Total environmental impact (normalized) per scenario
         ;
         eTranspImpact(trm,beta)..               vTranspImpact(trm,beta)      =E= sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and t_truck(trm)), pTranspImpact(trm,beta)*dist(lo,ld)*(1 + 1*pProductWeight(m)*Flow(lo,ld,m,trm,t,y)))
                                                                                 +sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and (t_plane(trm) or t_boat(trm))), pTranspImpact(trm,beta)*pProductWeight(m)*dist(lo,ld)*Flow(lo,ld,m,trm,t,y));
         eProductionImpact(p,r,beta)..           vProductionImpact(p,r,beta)     =E= sum((f,t,y), convertKWH_CO2*(pProductionEnergy(beta,r,p)*Production(f,p,t,y)));
         eMatImpact(beta)..                      vMatImpact(beta)                =E= sum((sup,ld,m,t,y), mFootprint(beta,m,sup)*MatOrder(sup,ld,m,t,y));
         eEntityImpact(beta)..                   vEntityImpact(beta)             =E= sum(w, pEntImpWarehouse(beta)*Open(w));
         eEnvHolding(beta)..                     vHoldingImpact(beta)            =E= sum((l,m,t,y), holding_impact(m)*StockLevel(l,m,t,y));
         eEnvImpactPerCategory(beta)..           vEnvImpactPerCategory(beta)     =E= sum(trm, vTranspImpact(trm,beta)) + sum((p,r), vProductionImpact(p,r,beta)) + vEntityImpact(beta) + vMatImpact(beta) + vHoldingImpact(beta);
         eEnvImpact..                            vEnvImpact                      =E= (-1)*sum(beta$(ord(beta)=1), pNormFactor(beta)*vEnvImpactPerCategory(beta));

*Only CC is being used. Energy is converted to CO2 eq

*############ SOCIAL DIMENSION #############

set       alpha social impact categories / alpha1 /;
parameter pTranspSocImpact(trm,alpha)          Characterization factor (per km) for environmental impact of transport mode trm in midpoint category alpha
          pManufSocImpact(alpha,m)    Characterization factor (per kg) for environmental impact of production of product m through resource r in midpoint category alpha
*          pEntityImpact(l,beta)            Characterization factor (per m2) for environmental impact of entity i
*          pEntImpFactory(beta)           Characterization factor (per m2) for environmental impact of factories
         ;

Table     pTranspSocImpact(trm,alpha)
                 alpha1
truck_own        3
truck_out        2
truckCOOL_own    3
truckCOOL_out    2
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
         vHoldingSocImpact(alpha)           Social impaact of storage
         vManufSocImpact(m,alpha)     Social impact of production of product m in category alpha
         vSocImpactPerCategory(alpha)     Total social impact per category alpha
         vSocImpact                      Total social impact
         ;
*         vSocImpact.fx(m,alpha)$(not p(m))=0;

equation eTranspSocImpact(trm,alpha)           Social impact of transportation mode trm per category alpha
         eSocHolding(alpha)                 Social impact of holding stock
         eManufSocImpact(m,alpha)        Social impact of production of product m per category alpha
         eSocImpactPerCategory(alpha)     Total social impact per category alpha
         eSocImpact                     Total social impact
         ;
*         eTranspSocImpact(trm,alpha)..               vTranspSocImpact(trm,alpha)      =E= sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and t_truck(trm)), pTranspSocImpact(trm,alpha)*dist(lo,lo)*(1 + 1*pProductWeight(m)*Flow(lo,ld,m,trm,t,y)))
*                                                                                 +sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and (t_plane(trm) or t_boat(trm))), pTranspSocImpact(trm,alpha)*pProductWeight(m)*dist(lo,ld)*Flow(lo,ld,m,trm,t,y));
         eTranspSocImpact(trm,alpha)..               vTranspSocImpact(trm,alpha)      =E= sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and t_truck(trm)), pTranspSocImpact(trm,alpha)*Flow(lo,ld,m,trm,t,y))
                                                                                 +sum((m,lo,ld,t,y)$(networkConnected(trm,m,lo,ld) and (t_plane(trm) or t_boat(trm))), pTranspSocImpact(trm,alpha)*Flow(lo,ld,m,trm,t,y));
         eSocHolding(alpha)..                     vHoldingSocImpact(alpha)            =E= sum((l,m,t,y), soc_holding_impact(m)*StockLevel(l,m,t,y));
         eManufSocImpact(p,alpha)..           vManufSocImpact(p,alpha)     =E= sum((f,t,y), pManufSocImpact(alpha,p)*Production(f,p,t,y));
         eSocImpactPerCategory(alpha)..           vSocImpactPerCategory(alpha)     =E= sum(trm, vTranspSocImpact(trm,alpha)) + sum(p, vManufSocImpact(p,alpha)) + vHoldingSocImpact(alpha);
         eSocImpact..                            vSocImpact     =E= (-1)*sum(alpha, vSocImpactPerCategory(alpha));

obj1..   Objf('z1') =E= vNPV;
*obj2..   Objf('z2') =E= vEnvImpact;
*obj3..   Objf('z3') =E= vSocImpact;
obj4..    objective =E= sum(z, active(z)*Objf(z) );
*obj4..    objective =E= sum(z, 0.4*vNPV + 0.3*vEnvImpact + 0.3*vSocImpact);

model aero_model /all/;

$ontext
option MIP=convert;
*$onecho > kestrel.opt
*kestrel_solver conopt
*neos_server neos-server.org:3332
*$offecho
*$onecho > convert.opt
*Force
*ObjVar
*Pyomo aero_model.py
*CplexLP
*Terminate
*$offecho
$offtext

aero_model.dictfile=1;
aero_model.optfile=0;
aero_model.holdfixed=1;
aero_model.optcr=0.1;

file result;

$ontext
solve aero_model using MIP maximizing objective;
put_utility result 'gdxout' / 'results.gdx';
execute_unload Production.L, Flow.L, Forming.L, MatOrder.L, StockLevel.L, vFixedCapInvest.L, vCashFlow.L, HireResource.L, FireResource.L, Manuf_NrResource.L, Fleet.L, NrTrips.L, SellTruck.L,BuyTruck.L, manuf_var_cost.L, transp_var_cost.L, store_var_cost.L, vNPV.L;
display Production.L, Flow.L, Forming.L, MatOrder.L, StockLevel.L, vFixedCapInvest.L, vCashFlow.L, HireResource.L, FireResource.L, Manuf_NrResource.L, Fleet.L, SellTruck.L, BuyTruck.L, NrTrips.L, manuf_var_cost.L, transp_var_cost.L, store_var_cost.L, vNPV.L;
$offtext

loop (zz,
     active(z)=0;
     active(zz)=1;
     solve aero_model using MIP maximizing objective;
     results.L(z)=objective.L;
     display results.L;
     display Production.L, Flow.L, Forming.L, MatOrder.L, StockLevel.L, vFixedCapInvest.L, vCashFlow.L, HireResource.L, FireResource.L, Manuf_NrResource.L, NrTrips.L, manuf_var_cost.L, transp_var_cost.L, store_var_cost.L, vNPV.L;
*     , Fleet.L, SellTruck.L, BuyTruck.L
     put_utility result 'gdxout' / 'results_' zz.tl:0 '.gdx';
     execute_unload Production.L, Flow.L, Forming.L, MatOrder.L, StockLevel.L, vFixedCapInvest.L, vCashFlow.L, HireResource.L, FireResource.L, Manuf_NrResource.L, Fleet.L, NrTrips.L, SellTruck.L,BuyTruck.L, manuf_var_cost.L, transp_var_cost.L, store_var_cost.L, vNPV.L;
);
