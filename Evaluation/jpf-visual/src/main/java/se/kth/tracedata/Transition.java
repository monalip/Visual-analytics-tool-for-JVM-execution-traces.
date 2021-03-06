package se.kth.tracedata;

import java.util.Iterator;
import java.util.LinkedList;

import se.kth.tracedata.ChoiceGenerator;
import se.kth.tracedata.Step;
import se.kth.tracedata.ThreadInfo;

public interface Transition extends Iterable<Step> {
	public int getThreadIndex ();
	public ThreadInfo getThreadInfo();
	public ChoiceGenerator<?> getChoiceGenerator();
	// don't use this for step iteration - this is very inefficient
	public Step getStep (int index) ;
	public int getStepCount ();
	public String getOutput ();

	public Iterator<Step> iterator();
	public void addStep(Step step);
	public void setChoiceGenerator(ChoiceGenerator<ThreadInfo> cg);
	public void addJVMStep(LinkedList<Step> steplist);
	
}
