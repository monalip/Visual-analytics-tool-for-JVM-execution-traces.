package se.kth.tracedata.jpf;

<<<<<<< HEAD


public class Instruction extends se.kth.tracedata.Instruction {
	 gov.nasa.jpf.vm.Instruction jpfInstruction;
=======
import se.kth.tracedata.MethodInfo;

public class Instruction extends se.kth.tracedata.Instruction {
	 gov.nasa.jpf.vm.Instruction jpfInstruction;
	 
>>>>>>> 04a2dc071776c7773dee008f404eb0b1dbecb95d
	
	public Instruction(gov.nasa.jpf.vm.Instruction jpfInstruction)
	{
		this.jpfInstruction = jpfInstruction;
	}
	@Override
	public MethodInfo getMethodInfo() {
<<<<<<< HEAD
		return new MethodInfo(jpfInstruction.getMethodInfo());
=======
		return new se.kth.tracedata.jpf.MethodInfo(jpfInstruction.getMethodInfo());
>>>>>>> 04a2dc071776c7773dee008f404eb0b1dbecb95d
	}
	@Override
	public String getFileLocation() {
		return jpfInstruction.getFileLocation();
	}
	@Override
	public boolean isInstanceofJVMInvok() {
		if(jpfInstruction instanceof gov.nasa.jpf.jvm.bytecode.JVMInvokeInstruction)
		{
			return true;
		}
		else
		{
		return false;
		}
	}
	@Override
	// if jpfInstruction instanceof gov.nasa.jpf.jvm.bytecode.JVMInvokeInstruction then with the hepl of
	//instruction object we are calling methods getInvokedMethodName() and getInvokedMethodClassName()
	public String getInvokedMethodName() {
		
		String methodName = (( gov.nasa.jpf.jvm.bytecode.JVMInvokeInstruction) jpfInstruction).getInvokedMethodName();
		return methodName;
		
		//return jpfJVMinvokeinstruct.getInvokedMethodName();
	}
	@Override
	public String getInvokedMethodClassName() {
		String clsName = ((gov.nasa.jpf.jvm.bytecode.JVMInvokeInstruction) jpfInstruction).getInvokedMethodClassName();
		//String clsName = ((JVMInvokeInstruction) ins).getInvokedMethodClassName();
		return clsName;
	}
	
	@Override
	public boolean isInstanceofJVMReturnIns() {
		if(jpfInstruction instanceof gov.nasa.jpf.jvm.bytecode.JVMReturnInstruction)
		{
			return true;
		}
		else
		{
		return false;
		}
	}
	@Override
	public boolean isInstanceofLockIns() {
		if(jpfInstruction instanceof gov.nasa.jpf.jvm.bytecode.LockInstruction)
		{
			return true;
		}
		else
		{
		return false;
		}
	}
	@Override
	// jpfInstruction instanceof gov.nasa.jpf.jvm.bytecode.LockInstruction then we can method getLastLockRef with the help of instruction object
	public int getLastLockRef() {
		return ((gov.nasa.jpf.jvm.bytecode.LockInstruction)jpfInstruction).getLastLockRef();
	}
	@Override
	public boolean isInstanceofVirtualInv() {
		
		if(jpfInstruction instanceof gov.nasa.jpf.jvm.bytecode.VirtualInvocation)
		{
			return true;
		}
		else
		{
		return false;
		}
	}
	@Override
	public boolean isInstanceofFieldIns() {
		return(jpfInstruction instanceof gov.nasa.jpf.vm.bytecode.FieldInstruction);
		
		
	}
	@Override
	public String getVariableId() {
		return ((gov.nasa.jpf.vm.bytecode.FieldInstruction)jpfInstruction).getVariableId();
	}
<<<<<<< HEAD
=======
	@Override
	public void setMethodInfo(MethodInfo mi)
	{
	}
	@Override
	public String getLastlockName() {
		// TODO Auto-generated method stub
		return null;
	}
	
	
>>>>>>> 04a2dc071776c7773dee008f404eb0b1dbecb95d
	
}
