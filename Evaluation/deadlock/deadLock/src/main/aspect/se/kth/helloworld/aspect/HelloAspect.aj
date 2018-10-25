package se.kth.helloworld.aspect;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.aspectj.lang.JoinPoint.StaticPart;

import java.util.logging.*;





aspect HelloAspect {
	 Logger log = Logger.getLogger(HelloAspect.class.getName());
	 
	static  RuntimeData global= RuntimeData.getInstance();
	static String sign= null;
	static String locationName=null;
	static String sourceString=null ;
	static String packagename=null;
	static String pkgName=null;
	static String className=null;
	static String methodName=null;
	static String sourceLocation=null;
	static int lineNo = 0;
	static long thread=0;
	static String fieldName= null;
	static Thread threadaspectj= null;
	static String prevMethod= null;
	static Class cName = null;
	static int i =0;
	static boolean isDeadlock = false;
	static int firstTime = 0;
	static Map<Object, Long> threadLocklist = new HashMap<>();
	static long maxThreadId =0;
	private static boolean DEBUG = false;
	
	/*
	 * Instrumentation Scope 
	 * 
	 */
	pointcut instrumentationScope() : !within(HelloAspect) && !within(RuntimeData) && !cflow(within(HelloAspect));
	/**
	 * 
	 * Lock unlock for synchronize block
	 */
	//lock
	before(Object l): (lock()) && args(l) && instrumentationScope()
	{	
		
		synchronized (thisJoinPointStaticPart) 
		{
			updateLockInfo(thisJoinPointStaticPart,l);
					
					//log.log(Level.INFO,"Trace Synchronized lock block: "+thisJoinPoint.getKind()+ " Field Name "+fieldName+" Source Location: "+thisJoinPointStaticPart.getSignature()+" CalsName"+className+" Trace ThreadId "+ Thread.currentThread().getId()+" \n");
					
			
		}
	}
	
	
	// unlock Synchronize block
	//unlock pointcut for synchronized block
		after(Object l): (unlock()) && args(l) && instrumentationScope()
		{		
			synchronized (thisJoinPointStaticPart) 
			{
				updateUnlockInfo(thisJoinPointStaticPart,l);
		
						
						//log.log(Level.INFO,"Trace Synchronized lock block: "+thisJoinPoint.getKind()+" Field Name "+fieldName+" Source Location: "+thisJoinPointStaticPart.getSignature()+" CalsName"+className+" Trace ThreadId "+ Thread.currentThread().getId()+" \n");
						
				
			}
			
		}
		
	//Sychronized method
		//|| execution(public synchronized* *.*(..)
	pointcut synchPoint(Object l): (execution(public synchronized* *.*(..)) ) && target(l) && instrumentationScope(); // or call()}*/
	after(Object l): synchPoint(l) 
    {
		
		synchronized (thisEnclosingJoinPointStaticPart) {
			updateSynchMethodInfo(thisJoinPointStaticPart,l);
		}
			
		
    }
	
	
	/*pointcut lock(ReentrantLock l) : call(* ReentrantLock.lock()) && target(l) ;
	after(Object app): lock() && args(app) {

		System.out.println("around(App) lock: advice running at "+thisJoinPoint.getSourceLocation());

	
	
    pointcut syncJointPoint(): execution( Synchronizes * *.*(..)); // or call()}*/

    /*Object around(): syncJointPoint() {
        synchronized(lock) {
        	System.out.println("around(App) lock: advice running at "+thisJoinPoint.getSourceLocation());

            return proceed();
        }
    }
    after(Object lock):execution( Synchronizes * *.*(..)) && !within(HelloAspect) && target(lock)
    {
    	System.out.println("around(App) lock: advice running at "+thisJoinPoint.getSourceLocation());

    }*/
    /*before() :
        if(!DEBUG) && (
            call(* Thread+.start()) ||
            call(* ExecutorService+.execute(..)) ||
            call(* ExecutorService+.submit(..)) ||
            call(* ExecutorService+.invokeAll(..)) ||
            call(* ExecutorService+.invokeAny(..)) ||
            call(* ScheduledExecutorService.scheduleAtFixedRate(..))
        )
    {
        System.out.println("First:   "+Thread.currentThread());
    }

    before() :
        if(DEBUG) &&
        within(*) &&
        !within(HelloAspect) &&
        !get(* *) &&
        !call(* println(..))
    {
        System.out.println("Second: " +thisJoinPoint);
    }*/
	
	/*after(Object lock):execution( synchronized* *.*(..)) && !within(HelloAspect) && target(lock)
    {
    	//System.out.println("around(App) lock: advice running at "+thisJoinPoint.getSourceLocation());

    }*/
		
	
	/*
	 * ReentrantLock unlock
	 * 
	 * */
		//pointcut lock(ReentrantLock l ): call (* ReentrantLock.lock ()) && target(l ) && instrumentationScope();
		//pointcut unlock(ReentrantLock l ): call (* ReentrantLock.unlock ()) && target(l ) && instrumentationScope();
		before(ReentrantLock l):call (* ReentrantLock.lock ()) && target(l ) && instrumentationScope()
		{
			synchronized (this) 
			{
				
				updateReentrantLockInfo(thisJoinPointStaticPart,l);
			}
			
			
			
		}
		
		after(ReentrantLock l): call (* ReentrantLock.unlock ()) && target(l ) && instrumentationScope()
		{
			synchronized (thisJoinPointStaticPart) 
			{
				updateReentrantUnlockInfo(thisJoinPointStaticPart,l);
			}
			
			
		}
		
		/**
		 * 
		 * thread start information to create the list of the started thread
		 * */
		after(Thread childThread) : call(* Thread+.start()) && instrumentationScope() && target(childThread)
		{
			//log.log(Level.INFO, "pointcut:" + thisJoinPoint.getKind()+" Trace method ThreadId "+ childThread.getName()+" \n");
			if(childThread.getId() > maxThreadId)
			{
				maxThreadId = childThread.getId();
				global.maxThreadId = maxThreadId;
			}
			global.threads.add(childThread);
			
		}

	
	/**
	 * 
	 * method inforamtion
	 * */
		pointcut constructionCall() : (execution(*.new(..)) || initialization(*.new(..)));
		
	pointcut traceThrowingExceptionCall() : execution(* *(..) throws Exception+) || execution(* *(..) throws Exception+);
	pointcut javaPackageRealtedCall(): call(* java..*.*(..)) || call(* java.lang.Object.*(..));
	pointcut threadRealatecall():( call(Thread+.new(..)) || call(* Thread+.wait()) || call(* Thread+.notify()) || call(* Thread+.notifyAll())) && (!call(* Thread+.start()) && ! call(* Thread+.join()));	
	//pointcut traceMethod(): (execution (* *.*(..)) || execution(*.new(..)) || initialization(*.new(..)) || call(* java..*.*(..)) || call(void java.io.PrintStream.println(..)) || call(public void java.lang.Thread.start()))   && !cflow(within(HelloAspect)) ;
	pointcut traceMethod(): (execution (* *.*(..)) ||threadRealatecall()|| constructionCall()  || javaPackageRealtedCall() || traceThrowingExceptionCall())  && !threadRealatecall() &&!(execution(synchronized* *.*(..))) &&  instrumentationScope() ;
	before(): traceMethod() 
	{
		
			synchronized (thisJoinPointStaticPart) 
			{
				updateMethodInfo(thisJoinPointStaticPart);
			}
			
			
	}
	
	//Thread related operation
	after (Thread childThread) : (call(* Thread+.start()) ||call(* Thread+.join())) && instrumentationScope() && target(childThread)
	{
		
		synchronized (thisEnclosingJoinPointStaticPart) 
		{
			
			if(thisEnclosingJoinPointStaticPart.getSignature().getName().length() > 0 && (prevMethod != thisEnclosingJoinPointStaticPart.getSignature().getName()))
			{
			//System.out.println("After method "+ i+" \n");
			sign = (thisJoinPointStaticPart.getSignature()).toString();
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisEnclosingJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();
			//System.out.print("method Name:"+methodName+"\n");
			
			thread = getThreadId(Thread.currentThread());
			fieldName="";
			
			if(methodName=="start")
			{
				 //System.out.print("Method Name "+methodName+"\n");
				methodName = getmethodName(thisJoinPointStaticPart);
			}
			else if(methodName=="join") {
				//System.out.print("Method Name "+methodName+"\n");
				methodName = getmethodName(thisJoinPointStaticPart);
			}
				
			
	
				//log.log(Level.INFO,"Trace method methodName "+ methodName+" pointcut:" + thisJoinPoint.getKind()+" Trace method ThreadId "+ Thread.currentThread().getId()+" \n");
				updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
			
					
						global.createInvokeInstruction();
			
				
			}
			
			
			
			prevMethod =methodName;
			methodName ="";
		}
		
		
	}

	
	private void updateThreadInfo(StaticPart thisJoinPointStaticPart) {
		// TODO Auto-generated method stub
		
	}
	/**
	 *
	 * field inforamtion
	 * */
	//get fiels access
	pointcut getObject() : (get(* *.*) || set(* *.*) ) && instrumentationScope();
	before() : getObject()
	{
		synchronized (thisJoinPointStaticPart) {
			updateFieldInfo(thisJoinPointStaticPart);
		}
	
	}
	
	
	
	
	/*
	 * 
	 * Instrument the end of main method before start the visualization 
	 * 
	 * 
	 */
	
		pointcut mainMethod() : execution(public static void main(String[]));
	/**
	 * Pointcut to trace the execution of every method in class as long as the control flow isn’t in the current class
	 */
		
	   after() : mainMethod() 
	   {
		 
		   for(Thread t:global.threads)
		   {
			  //use try catch as   t.join() throws InterruptedException if it detects that the current thread has its interrupt flag set
			   //main thread is entered in the waiting state until other thread completes its execution.
			   try {
				   t.join();
				
			} catch (Exception e) {
				System.out.println(e);
			}
		   }
		   System.out.println("The application has ended...");
		   //Start GUI
		  
			  global.displayErrorTrace();
		   
		   
		   // clear the threadList
		   global.threads.clear();
	   }
	   //Get and uodate information
	   //update Synchronized method info
	   private static synchronized  void updateSynchMethodInfo(StaticPart thisJoinPointStaticPart,Object l) {
			sign = getSign(thisJoinPointStaticPart);
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();	//System.out.println("Second: " +methodName);
			thread = getThreadId(Thread.currentThread());
			fieldName="";
			updateSynmethod(true);
			//global.isSync=true;
			//System.out.println("AspectJ ClassName: " +className+"Method Name "+methodName+"\n");
			//log.log(Level.INFO,"Trace method methodName "+ methodName+" pointcut:" + thisJoinPoint.getKind()+" Trace method ThreadId "+ Thread.currentThread().getId()+" \n");
			threadLocklist.put(l,thread);
			updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
			global.createJVMReturnInstr();
			
			
		methodName = "";
			
		}
	   //update lock information for synchronized block
	   private static synchronized void updateLockInfo(StaticPart thisJoinPointStaticPart, Object l) {
			sign = getSign(thisJoinPointStaticPart);
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();	
			thread = getThreadId(Thread.currentThread());
			
			fieldName=getFieldNamelock(l.toString(),className);
			
			//System.out.println("Second: " +fieldName+"ClassName"+methodName+"\n");
			if(lineNo != 0 && fieldName.length()>0)
			{	
				if(thisJoinPointStaticPart.getKind().toString()=="lock")
				{
					global.isSynchBlock=true;
				}
				threadLocklist.put(l,thread);
				updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
					global.createLockInstruction();

			}
			fieldName="";
		
			
		}
	   //update unlock information for synchronized block
	   private static synchronized void updateUnlockInfo(StaticPart thisJoinPointStaticPart, Object l) {
			sign = getSign(thisJoinPointStaticPart);
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();	//System.out.println("Second: " +methodName);
			thread = getThreadId(Thread.currentThread());
			fieldName=getFieldNamelock(l.toString(),className);
			
			//System.out.println("Second: " +fieldName+"ClassName"+methodName+"\n");
			if(lineNo != 0 && fieldName.length()>0)
			{	
				if(thisJoinPointStaticPart.getKind().toString()=="unlock")
				{
					global.isUnLock=true;
				}
				threadLocklist.put(l,thread);
				updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
					global.createLockInstruction();

			}
			
			fieldName="";
		}
	   //Update the ReentrantLockInfo
	   private static synchronized void updateReentrantLockInfo(StaticPart thisJoinPointStaticPart,Object l) {

			sign = getSign(thisJoinPointStaticPart);
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();	//System.out.println("Second: " +methodName);
			thread = getThreadId(Thread.currentThread());
			fieldName=getFieldNamelock(l.toString(),className);
			if(lineNo != 0 && fieldName.length() > 0)
			{	
				
					global.isSynchBlock=true;
				
				threadLocklist.put(l,thread);
				updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
					global.createLockInstruction();

			}
			//System.out.println("AspectJ ClassName: " +className+"Method Name "+methodName+"\n");
			//System.out.println("Field: " +fieldName);
			//log.log(Level.INFO,"Trace Synchronized lock block: "+thisJoinPoint.getKind()+ "Field Name"+fieldName+" Source Location: "+sourceLocation+" CalsName"+className+" Trace ThreadId "+ Thread.currentThread().getId()+" \n");
			
	
			fieldName ="";
		
	}
	   //updateReentrantUnlockInfo
	   private static synchronized void updateReentrantUnlockInfo(StaticPart thisJoinPointStaticPart, Object l) {
			sign = getSign(thisJoinPointStaticPart);
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();	//System.out.println("Second: " +methodName);
			thread = getThreadId(Thread.currentThread());
			fieldName=getFieldNamelock(l.toString(),className);
			if(lineNo != 0)
			{	
				
				
					global.isSynchBlock=true;
				
				threadLocklist.put(l,thread);
				updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
					global.createLockInstruction();

			}
			//System.out.println("AspectJ ClassName: " +className+"Method Name "+methodName+"\n");
			//log.log(Level.INFO,"Trace Synchronized lock block: "+thisJoinPoint.getKind()+ "Field Name"+fieldName+" Source Location: "+sourceLocation+" CalsName"+className+" Trace ThreadId "+ Thread.currentThread().getId()+" \n");
			
	
			fieldName ="";
		}
	
	   // update the captured field Inforamtion and create the createFieldInstruction
	   private static synchronized void updateFieldInfo(StaticPart thisJoinPointStaticPart) {
			if(thisJoinPointStaticPart.getSignature().getName().length()>0 && thisJoinPointStaticPart.getSignature().getName() != "out" )
			{
				
					 // after() returning(Object field) : get( * *) && within(se.kth.helloworld.App)&& !within(HelloAspect){
					sign = (thisJoinPointStaticPart.getSignature()).toString();
					packagename = getpackagename(thisJoinPointStaticPart);
					pkgName = getpkgName(thisJoinPointStaticPart);
					className = getclassName(pkgName);
					fieldName = getFieldValue(thisJoinPointStaticPart);
					thread = getThreadId(Thread.currentThread());
					sourceLocation = getsourceLocation(thisJoinPointStaticPart);
					locationName = getlocationName(sign);
					lineNo = getlineNo(sourceLocation);
					methodName= "";
					threadaspectj = Thread.currentThread();
					//System.out.println("Field Name "+ className+" \n");
					//System.out.println("ThreadId Name "+ Thread.currentThread().getId()+" \n");
				
				
					updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
					//log.log(Level.INFO,"getObject fieldName "+ fieldName+" Trace method ThreadId "+ Thread.currentThread().getId()+" \n");
					global.createFieldInstruction();
				}
				
			
			fieldName="";
			
		}
	   //update the method information and create the instruction of rightype
	   private static synchronized void updateMethodInfo(StaticPart thisJoinPointStaticPart) {
			if(thisJoinPointStaticPart.getSignature().getName().length() > 0 && (prevMethod != thisJoinPointStaticPart.getSignature().getName()))
			{
			//System.out.println("After method "+ i+" \n");
			sign = (thisJoinPointStaticPart.getSignature()).toString();
			locationName = sign.toString();
			sourceString = getsourceString(locationName);
			packagename = getpackagename(thisJoinPointStaticPart);
			pkgName = getpkgName(thisJoinPointStaticPart);
			className = getclassName(pkgName);
			methodName = getmethodName(thisJoinPointStaticPart);
			sourceLocation = getsourceLocation(thisJoinPointStaticPart);
			lineNo = getlineNo(sourceLocation);
			threadaspectj = Thread.currentThread();
			
			//System.out.print("method Name:"+methodName+"\n");
			
			thread = getThreadId(Thread.currentThread());
			fieldName="";
			
			

				//log.log(Level.INFO,"Trace method methodName "+ methodName+" pointcut:" + thisJoinPoint.getKind()+" Trace method ThreadId "+ Thread.currentThread().getId()+" \n");
				updateGlobalVar(sign,className,methodName,thread,sourceLocation,lineNo,fieldName,threadaspectj,packagename);
				if(methodName=="wait")
				{
					
					global.createVirtualInvocationIns();
				}
				else
				{
					
						global.createInvokeInstruction();
					
					
				}
				
			}
			
			
			
			prevMethod =methodName;
			methodName ="";
			fieldName="";
		
			
		}
	   //Update the field required to create th proper data structure
	   private static synchronized String getSign(StaticPart thisJoinPointStaticPart) {
			return(thisJoinPointStaticPart.getSignature().toString());
		}
	   private static synchronized  String getpackagename(StaticPart thisEnclosingJoinPointStaticPart) {
			return thisEnclosingJoinPointStaticPart.getSignature().getDeclaringTypeName();
		}
	   private static synchronized String getsourceString(String locationName) {
			return locationName.substring(locationName.lastIndexOf('.') + 1);
		}
	   private static synchronized String getpkgName(StaticPart thisJoinPoint) {
			return thisJoinPoint.getSignature().getDeclaringTypeName();
		}
	   private static synchronized String getclassName(String pkgName) {

			return pkgName.substring(pkgName.lastIndexOf('.') + 1);
		}
	   private static synchronized  String getmethodName(StaticPart thisJoinPointStaticPart) {
			return thisJoinPointStaticPart.getSignature().getName();
		}

	   private static synchronized  String getsourceLocation(StaticPart thisJoinPointStaticPart) {
			// TODO Auto-generated method stub
			return thisJoinPointStaticPart.getSourceLocation().toString();
		}
	   private static synchronized int getlineNo(String sourceLocation) {
			return Integer.parseInt(sourceLocation.substring(sourceLocation.lastIndexOf(':') + 1));
		}
	   private static synchronized  long getThreadId(Thread currentThread) {
			
			return currentThread.getId();
		}
	   private static synchronized String getFieldName(Object l) {
			
			return l.toString();
		}
	   private static synchronized String getFieldValue(StaticPart thisJoinPointStaticPart) {
			
			return thisJoinPointStaticPart.getSignature().getName();
		}
	   private static synchronized String getlocationName(String sign) {
			
			return sign.toString();
		}
	   private static synchronized String getFieldNamelock(String fieldName, String className) {
			String f;
			Pattern pat = Pattern.compile("@", Pattern.CASE_INSENSITIVE);
	        Matcher mat = pat.matcher(fieldName);
	        if(mat.find())
	        {
	           
				f=fieldName.substring(fieldName.lastIndexOf('.') + 1);
				f=f.substring( 0, f.indexOf("@"));
				return f;
	        }
			else
			{
				
				return className;
			}
			
		}
	   private static synchronized void updateSynmethod(boolean b) {
			global.isSync=true;
			
		}
	   public static synchronized void updateGlobalVar(String sign,String className,String methodName,long thread,String sourceLocation,int lineNo,String fieldName, Thread threadaspectj, String pkgName)
	   {
		   
		    global.sig= sign.toString();	
			global.cname=className;
			global.mname=methodName;
			global.threadId = thread;
			global.sourceLocation=sourceLocation;
			global.locationNo = lineNo;
			global.fname=fieldName;
			global.eventThread =threadaspectj;
			global.pkgName =pkgName;
			//System.out.println("Aspectj Method Name "+ methodName+" \n");
			//System.out.println("Aspectj Field Name "+ fieldName+" \n");
			
			
			
			
		
	   }
	   

	   
	   
}
