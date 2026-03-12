$Inverter HSPICE setup file

$transistor model
.include "/proj/cad/library/mosis/GF65_LPe/cmos10lpe_CDS_oa_dl064_11_20160415/models/YI-SM00030/Hspice/models/design.inc"
.include "/home/013/f/fx/fxh220001/cad/gf65/inv_LVS/inv.pex.sp"

.option post runlvl=5

xi GND! OUT VDD! IN inv

vdd VDD! GND! 1.2v

vin IN GND! pwl(0ns 0v 0.0333ns 1.2v 6ns 1.2v 6.0333ns 0v 12ns 0v 12.0333ns 1.2v 18ns 1.2v 18.0333ns 0v 24ns 0v)
cout OUT GND! 31f

$transient analysis
.tr 100ps 24ns

.measure tran trise trig v(IN) val=0.6v fall=1 targ v(OUT) val=0.6v rise=1
.measure tran tfall trig v(IN) val=0.6v rise=1 targ v(OUT) val=0.6v fall=1
.measure tavg param='(trise+tfall)/2'
.measure tdiff param='abs(trise-tfall)'
.measure delay param='max(trise,tfall)'

$method 2
.measure tran t1 when v(IN)=1.19 fall=1
.measure tran t2 when v(OUT)=1.19 rise=1
.measure tran t3 when v(IN)=0.01 rise=1
.measure tran t4 when v(OUT)=0.01 fall=1
.measure tran i1 avg i(vdd) from=t1 to=t2
.measure tran i2 avg i(vdd) from=t3 to=t4
.measure energy1 param='1.2*i1*(t2-t1)'
.measure energy2 param='1.2*i2*(t4-t3)'
.measure energysum param='energy1+energy2'
.measure edp2 param='abs(delay*energysum)'

.end

