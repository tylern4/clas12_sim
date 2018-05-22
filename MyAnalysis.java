import java.util.ArrayList;
import java.util.Arrays;

import org.jlab.analysis.plotting.H1FCollection2D;
import org.jlab.analysis.plotting.H1FCollection3D;
import org.jlab.analysis.plotting.TCanvasP;
import org.jlab.analysis.plotting.TCanvasPTabbed;
import org.jlab.analysis.math.ClasMath;
import org.jlab.clas.physics.Particle;
import org.jlab.groot.data.H1F;
import org.jlab.groot.data.H2F;
import org.jlab.io.base.DataBank;
import org.jlab.io.base.DataEvent;
import org.jlab.io.hipo.HipoDataSource;

public class MyAnalysis {

	public H1FCollection2D e_gen_phi; // e- gen. phi distribution in bins of p and theta
	public H1FCollection2D e_rec_phi; // e- rec. phi distribution in bins of p and theta
	public H1FCollection3D e_DpOp; // e- p resolution (Delta p / p) in bins of p, theta, and (relative) phi
	public H1FCollection3D pip_DpOp; // pi+ p resolution (Delta p / p) in bins of p, theta, and (relative) phi


	public MyAnalysis() {
		e_gen_phi = new H1FCollection2D("e_gen_phi", 100, -180, 180,       // phi histograms have 100 bins from -180 to 180
			new ArrayList<>(Arrays.asList(0.5, 3.9, 7.3, 10.5)),            // p bin limits
			new ArrayList<>(Arrays.asList(0.0, 10.0, 20.0, 30.0)));         // theta bin limits
		e_gen_phi.setTitleX("#phi (deg)");
		
		e_rec_phi = new H1FCollection2D("e_rec_phi", 100, -180, 180,       // phi histograms have 100 bins from -180 to 180
			new ArrayList<>(Arrays.asList(0.5, 3.9, 7.3, 10.5)),            // p bin limits
			new ArrayList<>(Arrays.asList(0.0, 10.0, 20.0, 30.0)));         // theta bin limits
		e_rec_phi.setLineColor(2);
		
		e_DpOp = new H1FCollection3D("e_DpOp", 100, -0.05, 0.05,           // Delta p / p histograms have 100 bins from -0.05 to 0.05
			new ArrayList<>(Arrays.asList(0.5, 3.9, 7.3, 10.5)),            // p bin limits
			new ArrayList<>(Arrays.asList(0.0, 10.0, 20.0, 30.0)),          // theta bin limits
			new ArrayList<>(Arrays.asList(-30.0, -15.0, 15.0, 30.0)));      // (relative) phi bin limits
		e_DpOp.setTitleX("e- #Delta p/p");
		
		pip_DpOp = new H1FCollection3D("pip_DpOp", 100, -0.05, 0.05,       // Delta p / p histograms have 100 bins from -0.05 to 0.05
			new ArrayList<>(Arrays.asList(0.5, 3.9, 7.3, 10.5)),            // p bin limits
			new ArrayList<>(Arrays.asList(0.0, 20.0, 40.0, 125.0)),         // theta bin limits
			new ArrayList<>(Arrays.asList(-30.0, -15.0, 15.0, 30.0)));      // (relative) phi bin limits
		pip_DpOp.setTitleX("#pi+ #Delta p/p");
	}


	public void processEvent(DataEvent event) {
		// get generated particles
		Particle gen_e = null;
		Particle gen_gamma = null;
		Particle gen_pip = null;
		if(event.hasBank("MC::Particle") && event.getBank("MC::Particle").rows() == 3) {
			DataBank mcBank = event.getBank("MC::Particle");
			gen_e = new Particle(11, mcBank.getFloat("px", 0), mcBank.getFloat("py", 0), mcBank.getFloat("pz", 0));
			gen_gamma = new Particle(22, mcBank.getFloat("px", 1), mcBank.getFloat("py", 1), mcBank.getFloat("pz", 1));
			gen_pip = new Particle(211, mcBank.getFloat("px", 2), mcBank.getFloat("py", 2), mcBank.getFloat("pz", 2));
		}
	
		// get reconstructed particles
		Particle rec_e = null;
		Particle rec_gamma = null;
		Particle rec_pip = null;
		if(event.hasBank("REC::Particle") && event.getBank("REC::Particle").rows() > 0 && event.getBank("REC::Particle").rows() <= 3) {
			DataBank recBank = event.getBank("REC::Particle");
			for(int k = 0; k < recBank.rows(); k++) {
				if(recBank.getByte("charge", k) == -1) rec_e = new Particle(11, recBank.getFloat("px", k), recBank.getFloat("py", k), recBank.getFloat("pz", k));
				else if(recBank.getByte("charge", k) == 0) rec_gamma = new Particle(22, recBank.getFloat("px", k), recBank.getFloat("py", k), recBank.getFloat("pz", k));
				else if(recBank.getByte("charge", k) == 1) rec_pip = new Particle(211, recBank.getFloat("px", k), recBank.getFloat("py", k), recBank.getFloat("pz", k));
			}
		}
	
		// fill histograms
		if(gen_e != null) e_gen_phi.fill(Math.toDegrees(gen_e.phi()), gen_e.p(), Math.toDegrees(gen_e.theta()));
		if(rec_e != null) e_rec_phi.fill(Math.toDegrees(rec_e.phi()), rec_e.p(), Math.toDegrees(rec_e.theta()));
		if(gen_e != null && rec_e != null) e_DpOp.fill((gen_e.p() - rec_e.p())/gen_e.p(), gen_e.p(), Math.toDegrees(gen_e.theta()), Math.toDegrees(ClasMath.getRelativePhi(gen_e.phi())));
		if(gen_pip != null && rec_pip != null) pip_DpOp.fill((gen_pip.p() - rec_pip.p())/gen_pip.p(), gen_pip.p(), Math.toDegrees(gen_pip.theta()), Math.toDegrees(ClasMath.getRelativePhi(gen_pip.phi())));
	}


	public void plot() {
		TCanvasP e_phi_can = new TCanvasP("e_phi_can", 1000, 800);
		e_phi_can.draw(e_gen_phi);
		e_phi_can.draw(e_rec_phi, "same");
		
		TCanvasPTabbed e_DpOp_can = new TCanvasPTabbed("e_DpOp_can", 1000, 800);
		e_DpOp_can.draw(e_DpOp);
		
		TCanvasPTabbed pip_DpOp_can = new TCanvasPTabbed("pip_DpOp_can", 1000, 800);
		pip_DpOp_can.draw(pip_DpOp);
	}


	public static void main(String[] args) {
		MyAnalysis ana = new MyAnalysis();
	
		HipoDataSource reader = new HipoDataSource();
		reader.open("out_sim.hipo");
		
		int count = 0;
		while(reader.hasEvent()) {
			DataEvent event = reader.getNextEvent();
			ana.processEvent(event);
			count++;
			if(count%500 == 0) System.out.println(count);
		}
		
		reader.close();
		ana.plot();
	}


}
