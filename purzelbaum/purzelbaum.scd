


|||||||            |||||||
|||||||      |     || af |
||||||| |          |||||||
|||||||            |||||||



     || PURZELBAUM ||

||  multichannel tester ||


(




		//INITS
	var w,s1,s2,s3,s4,s5,nb,nb2,
		cl,cl2,cl3,
		c1=0,c2,sw=0,sw2=0,sw3=0,sw4=0,r1,sfv,
		txt1,txt2,txt3,txt4,txt5,txt6,lv;

		//channels/globals
		~chnum=2;
		~ch_d=0;

		//distance of speakers (works only in circle mode)
		~s_dis=0.5;


		//SERVERSETTING
		s = Server.local;
		s.options.memSize= 262144;
		s.latency = nil;



		//random COLORS
		cl = Color.rand(0.3,0.4);
		cl2 = Color.rand(0.8,0.9);
		cl3 = Color.rand(0.5,0.7);

		//WINDOW and centering
		w = Window("PURZELBAUM",Rect(0,0,200,200),false,false).front.background_(cl2).alwaysOnTop_(true);
		w.bounds = w.bounds.center_(Window.screenBounds.center*0.9 );

		//mai Spawn button
		~b1 = Button(w,Rect(2,2,196,196))
				.canFocus_(false)
				.states_([["PURZEL \n:\n BAUM ",cl,cl2],["     RESET     ",cl2,cl3]])
				.font_(Font.monospace(38))
				.action_({|a|a = case {~b1.value==1} {sw=1;

				//DIALOG OPTIONS AND SPAWN
				Dialog.openPanel({ |path|

				//creates a mono buffer
				b = Buffer.readChannel(s, path.postln, channels: [0]);

				//resize of the window when file chosen
				w.bounds = w.bounds.resizeTo(850,200);
				v.remove;
				//view for custom content
				v=View(w,Rect(200,0,600,200));


				//play/pause button which creates ndef
		   ~b2 = Button(v,Rect(70,135,60,60))
				.canFocus_(false).states_([["PLAY",cl,cl2],["PAUSE",cl2,cl3]])
				.font_(Font.monospace(13))
				.action_({|a|a = case {~b2.value==1} {sw3=1;

					//SYNTH ON PLAY
		   ~s_out = Ndef(\sun, {|sun,pitch=1,blength,start=0,end=1,rate,speed,mode=0,
								 in_ch=0,f_out,cyc,edge=0, wobble,rn=0,ch=3,env=0,vol=0,smooth,reverse|

								blength = BufFrames.kr(b);

								//length of loop + random distribution
								wobble = TRand.kr(1-rn,1+rn,SinOsc.kr(1+rn));
								speed = end-start*wobble*BufDur.kr(b)/pitch;
								cyc = SinOsc.kr(1/speed);

								//reverse array
								reverse = [ 1.0, -1.0];

								//SAMPLER with start,end,transposition and reverse
								sun = Phasor.ar(0,BufRateScale.kr(b)*pitch
									 *(Select.kr(cyc+2*env.abs,reverse)),blength*start,blength*end,200);
								sun = BufRd.ar(1,b,sun);

								rate= [
										//3 selectable modes -> cycle, random, manually

										Stepper.kr(cyc,0,0,ch-1),

										TRand.kr(0,ch-1,cyc).round(1),

										in_ch,

									  ];

									//external selector for modes
									f_out = Select.kr(mode,rate);

									//sends current channel as osc message (\tr)
									SendTrig.kr(SinOsc.kr(1/speed),0,f_out);

								//distortion via rounding
								sun=sun.round(edge);

								//Output+AMP

								Out.ar(f_out,sun*vol);

								});}

								//reset options
								{~b2.value==0} {sw4=1;~s_out.free}});

				~s_out.set(\vol, 0);
				~s_out.set(\start,0);
				~s_out.set(\end, 1);
				~s_out.set(\rn, 0);
				~s_out.set(\env,0);
				~s_out.set(\edge, 0);
				~s_out.set(\ch, 2);
				~s_out.set(\mode, 0);
				//transpose slider
				s1 = Slider.new(v, Rect(180, 143, 90, 15));
				s1.action_({|r|  ~s_out.set(\pitch, r.value*2)}).value_(0.5).knobColor_(cl3).backColor_(cl3);
				txt2 = StaticText(v, Rect(180,125 , 90, 20))
				.align_(\center)
				.string_("Transposition")
				.stringColor_(cl)
				.font_(Font.monospace(9));

				//edge slider
				s2 = Slider.new(v, Rect(180, 178, 90, 15));
				s2.action_({|r|  ~s_out.set(\edge, r.value/10)}).value_(0).knobColor_(cl3).backColor_(cl3);
				txt3 = StaticText(v, Rect(180,160 , 90, 20))
				.align_(\center)
				.string_("Edge")
				.stringColor_(cl)
				.font_(Font.monospace(9));


				//length slider
				s3 = Slider.new(v, Rect(275, 143, 90, 15));
				s3.action_({|r|  ~s_out.set(\rn, r.value.linlin(0,1,0,0.8))}).value_(0).knobColor_(cl3).backColor_(cl3);
				txt3 = StaticText(v, Rect(275,125 , 90, 20))
				.align_(\center)
				.string_("Length Distro")
				.stringColor_(cl)
				.font_(Font.monospace(9));

				//Reverse slider
				s4 = Slider.new(v, Rect(275, 178, 90, 15));
				s4.action_({|r|  ~s_out.set(\env, r.value)}).value_(0).knobColor_(cl3).backColor_(cl3);
				txt4 = StaticText(v, Rect(275,160 , 90, 20))
				.align_(\center)
				.string_("Reverse Ratio")
				.stringColor_(cl)
				.font_(Font.monospace(9));

				//Volume slider
				s5 = Slider.new(v, Rect(135, 135, 25, 60));
				s5.action_({|r|  ~s_out.set(\vol, r.value)}).knobColor_(cl3)
				.value_(0.001).backColor_(cl3);
				txt5 = StaticText(v, Rect(162,135 , 10, 60))
				.align_(\center)
				.string_("A M P")
				.stringColor_(cl)
				.font_(Font.monospace(10));


				//SOUNDFILEVIEWER and buffer data
				sfv = SoundFileView.new(v, Rect(10,5, 430,120))
				.setSelectionColor(63,cl)
				.backColor_(cl2).gridOn_(false)
				.waveColors_([cl,cl3])
				.soundfile_(b);
				sfv.read(0,b.numFrames);
				sfv.refresh;



				//Max Channel setting
				nb = NumberBox(v, Rect(5, 145, 60, 50))
				.clipLo_(1)
				.clipHi_(64)
				.step_(1)
				.value_(~chnum)
				.backColor_(cl2)
				.align_(\center)
				.font_(Font.monospace(35))
				.action_({|m| ~chnum=m.value;nb2.clipHi = m.value;~s_out.set(\ch, m.value)});
				txt4 = StaticText(v, Rect(5,130 , 60, 20))
				.align_(\center)
				.string_("CHANNEL MAX")
				.stringColor_(cl)
				.font_(Font.monospace(9));

				//editable numberbox for "manually mode"
				nb2 = NumberBox(v, Rect(405, 178, 35, 15))
				.clipLo_(1)
				.clipHi_(~chnum)
				.step_(1)
				.visible_(false)
				.backColor_(cl2)
				.align_(\center)
				.typingColor_(Color.black)
				.font_(Font.monospace(13))
				.action_({|m| ~s_out.set(\in_ch, m.value-1)});
				txt5 = StaticText(v, Rect(373,177, 30, 20))
				.align_(\center)
				.string_("CH#:")
				.visible_(false)
				.stringColor_(cl)
				.font_(Font.monospace(12));

				//CHANNELCOUNTER
				Button(w,Rect(652,2,196,196))
				.states_([["         ",cl2,cl3]])
				.canFocus_(false);
				txt1 = StaticText(w, Rect(654, 5, 200, 200))
				.stringColor_(cl)
				.font_(Font.monospace(170));
				txt1.align = \center;
				sfv.refresh;

				//distance travelled
				txt6 = StaticText(w, Rect(654, 180, 200, 20))
				.stringColor_(cl2)
				.font_(Font.monospace(10));
				txt6.align = \center;



				//TRIGGER CATCH: receives OSC from ndef and displays counter
				o = OSCresponder(s.addr, '/tr', {|a,b,m| {

									txt1.string = m[3]+1;
									//distance measurement
									if(lv.value<1,{
									~ch_d=~ch_d+1;
									~dist = ~s_dis*~ch_d;
									txt6.string = "Your sample travelled" + ~dist.round(1) + "m";
										});
        							}.defer;
				}).add;

				//SAMPLE RANGE FINDER-> covers 2nd track of file
				r1 = RangeSlider(v, Rect(8, 67, 434, 60))
            	.lo_(0)
            	.hi_(1)
				.knobColor_(cl)
				.backColor_(cl2)
				.canFocus_(false)
            	.action_({|r|
                	~s_out.set(\start,r.lo,\end, r.hi);
            	});

				//menu for modes
				lv = ListView(v,Rect(370,135,70,40))
    			.items_([ "Cycle", "Random", "Manually"])
    			.background_(cl2)
    			.hiliteColor_(cl3)
				.value_(0)
				.font_(Font.monospace(9))
				.selection_(0)
    			.action_({ |m|
			        ~s_out.set(\mode, m.value);
					if(m.value>1,{nb2.visible=true;txt5.visible=true;

			} ,{nb2.visible=false;txt5.visible=false;});
    			});

				~s_out.set(\pitch, 1);

			},

				//exceptions on dialog cancel + RESET
				{ "couldn't load file".postln});~b1.value==0;}
				{~b1.value==0} {sw2=1;b.free;~s_out.set(\start,0);
								~s_out.set(\end, 1);~s_out.set(\mode, 0);~s_out.set(\rn,0);
								~s_out.set(\edge,0);~s_out.set(\vol,0);
								~s_out.set(\pitch, 1);v.destroy;
								~b2.value==0; w.bounds = w.bounds.resizeTo(200,200);}

		});

	//free all on window close
	w.onClose_({s.freeAll});
	CmdPeriod.doOnce { w.close };

"Purzelbaum - loaded".postln;

)




