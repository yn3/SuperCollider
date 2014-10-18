//////////////////////////
///////// TIBET v0.1
//////////////////////////



(       // double click + eva

s.waitForBoot
	{
	    // Mapping

		Spec.add(\klank1, #[1000, 16000, \exp]);

		Spec.add(\klank2, #[1000, 16000, \exp]);

		Spec.add(\hpf, #[80, 6000, \lin]);

		Spec.add(\vol, #[0.001,1.0, \lin]);

		Ndef(\tibet).play;

	    Ndef(\fadetime).fadeTime = 3;

		//  Synth

	    Ndef

	         (\tibet,

		             {

		arg klank1 = 7000, klank2 = 10000, hpf = 80, vol = 0.0;

		var shift = SinOsc.ar(0.001.rand,0,0.2,0.3);

		var fade = XLine.kr(0.01,1,3);

	    var haha = DynKlank.ar(`[[{klank1*1.00.rand}.dup(12)],[{SinOsc.kr(0.10.rand,0,0.4+0.1.rand,0.5)}.dup(12)]],PinkNoise.ar(0.004),0.1);

		var hehe = DynKlank.ar(`[[{klank2*1.00.rand}.dup(12)],[{SinOsc.kr(0.10.rand,0,0.4+0.1.rand,0.5)}.dup(12)]],PinkNoise.ar(0.005),0.1);

		var distance = CombC.ar(DynKlank.ar(`[[{klank2+klank1*1.0.rand+60}.dup(12)],[{SinOsc.kr(0.100.rand,0,0.2+0.18.rand,0.38)}.dup(12)]],PinkNoise.ar(0.0006),shift),shift,shift*2,shift*9);

		Out.ar(0,HPF.ar([haha+distance+(hehe*shift/10)*fade,hehe+distance+(haha*shift/10)*fade],hpf)*vol);

					}

			);

	    // GUI

		Ndef(\tibet).edit;

	}

)










