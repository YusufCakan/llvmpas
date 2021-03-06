; opt /e/mydata/work/llvmpas/release/lib/system.ll -O2 -S -o /e/mydata/work/llvmpas/release/lib/system.o2.ll
; opt system.ll -O2 -o system.o2.bc
; llc /e/mydata/work/llvmpas/release/lib/system.ll -filetype=asm
; llc /e/mydata/work/llvmpas/release/sources/rtl/ex.ll -filetype=asm -o /e/mydata/work/llvmpas/release/lib/i386-win32/rtl/ex.s
; llc /e/mydata/work/llvmpas/release/sources/rtl/ex.ll -filetype=obj -o /e/mydata/work/llvmpas/release/lib/i386-win32/rtl/ex.o

declare ccc i32 @printf(i8*, ...) nounwind

%msg1.ty = type [14 x i8]
@msg1 = private unnamed_addr constant %msg1.ty c"_RaiseExcept\0A\00"

@_ZTIPv = external constant i8*
declare i8* @__cxa_allocate_exception(i32)

declare i32 @__gxx_personality_v0(...)

declare void @__cxa_free_exception(i8*)

declare void @__cxa_throw(i8*, i8*, i8*)

declare void @__cxa_rethrow()

declare i8* @__cxa_begin_catch(i8*)

declare void @__cxa_end_catch()

declare void @_ZSt9terminatev()

declare void @exit(i32) noreturn nounwind

declare fastcc i32 @System._InternalHandleSafecall(i8*, i8*)

define fastcc void @System._CrtExit(i32 %code) noreturn
{
	tail call void @exit(i32 %code) noreturn
	unreachable
}

define fastcc void @System._RaiseExcept(i8* %exobj) noreturn
{
entry:
;	%.3 = call ccc  i32 (i8*, ...)* @printf(i8* getelementptr(%msg1.ty* @msg1, i32 0, i32 0))

  %exception = tail call i8* @__cxa_allocate_exception(i32 4) nounwind
  %0 = bitcast i8* %exception to i8**
  store i8* %exobj, i8** %0, align 4
  tail call void @__cxa_throw(i8* %exception, i8* bitcast (i8** @_ZTIPv to i8*), i8* null) noreturn
  unreachable
}

define void @System._Rethrow(i8* %exobj) noreturn
{
  invoke void @__cxa_rethrow() noreturn
          to label %unreachable unwind label %lpad2

lpad2:
  %.lp = landingpad { i8*, i32 } personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*)
          cleanup
  invoke void @__cxa_end_catch()
          to label %eh.resume unwind label %terminate.lpad

eh.resume:                                        ; preds = %lpad2
  resume { i8*, i32 } %.lp

terminate.lpad:                                   ; preds = %lpad2
  %.99 = landingpad { i8*, i32 } personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*)
          catch i8* null
  tail call void @_ZSt9terminatev() noreturn nounwind
  unreachable

unreachable:                                      ; preds = %lpad
  unreachable
}

define fastcc i32 @System._HandleSafecallExcept(i8* %obj, i8* %exPtr)
{
  %exobj = tail call i8* @__cxa_begin_catch(i8* %exPtr) nounwind
  tail call void @__cxa_end_catch()

  %.1 = call fastcc i32 @System._InternalHandleSafecall(i8* %obj, i8* %exobj)
  ret i32 %.1
}

define fastcc void @System._HandleCtorExcept(i8* %exPtr, i8* %obj, i8 %flag) noreturn
{
  %exobj = tail call i8* @__cxa_begin_catch(i8* %exPtr) nounwind
  ; call FreeInstance
  %.1 = bitcast i8* %obj to i8***
  %.2 = load i8*** %.1
  %.3 = getelementptr i8** %.2, i32 -2
  %.4 = load i8** %.3
  %.5 = bitcast i8* %.4 to void (i8*)*
  tail call fastcc void %.5(i8* %obj)

  ; rethrow exception
  invoke void @__cxa_rethrow() noreturn
          to label %unreachable unwind label %lpad2

lpad2:                                            ; preds = %lpad
  %.lp = landingpad { i8*, i32 } personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*)
          cleanup
  invoke void @__cxa_end_catch()
          to label %eh.resume unwind label %terminate.lpad

eh.resume:                                        ; preds = %lpad2
  resume { i8*, i32 } %.lp

terminate.lpad:                                   ; preds = %lpad2
  %.99 = landingpad { i8*, i32 } personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*)
          catch i8* null
  tail call void @_ZSt9terminatev() noreturn nounwind
  unreachable

unreachable:                                      ; preds = %lpad
  unreachable
}

; (i8* <dest>, i8 <val>, i32 <len>, i32 <align>, i1 <isvolatile>)
declare void @llvm.memset.p0i8.i32(i8*, i8, i32, i32, i1)
; (i8* <dest>, i8* <src>, i32 <len>, i32 <align>, i1 <isvolatile>)
declare void @llvm.memmove.p0i8.p0i8.i32(i8*, i8*, i32, i32, i1)

define fastcc void @System.FillChar(i8* %dest, i32 %size, i8 %val)
{
	call void @llvm.memset.p0i8.i32(i8* %dest, i8 %val, i32 %size, i32 1, i1 false)
	ret void
}

define fastcc void @System.Move(i8* %source, i8* %dest, i32 %count)
{
	call void @llvm.memmove.p0i8.p0i8.i32(i8* %dest, i8* %source, i32 %count, i32 1, i1 false)
	ret void
}

define fastcc i32 @System.InterLockedIncrement(i32* %dest)
{
	%1 = atomicrmw add i32* %dest, i32 1 seq_cst
	%result = add i32 %1, 1
	ret i32 %result
}

define fastcc i64 @System.InterLockedIncrement64(i64* %dest)
{
	%1 = atomicrmw add i64* %dest, i64 1 seq_cst
	%result = add i64 %1, 1
	ret i64 %result
}

define fastcc i32 @System.InterLockedDecrement(i32* %dest)
{
	%1 = atomicrmw sub i32* %dest, i32 1 seq_cst
	%result = sub i32 %1, 1
	ret i32 %result
}

define fastcc i64 @System.InterLockedDecrement64(i64* %dest)
{
	%1 = atomicrmw sub i64* %dest, i64 1 seq_cst
	%result = sub i64 %1, 1
	ret i64 %result
}

define fastcc i32 @System.InterLockedCompareExchange(i32* %dest, i32 %exchange, i32 %comparand)
{
	%1 = cmpxchg i32* %dest, i32 %comparand, i32 %exchange seq_cst
	ret i32 %1
}

define fastcc i64 @System.InterLockedCompareExchange64(i64* %dest, i64 %exchange, i64 %comparand)
{
	%1 = cmpxchg i64* %dest, i64 %comparand, i64 %exchange seq_cst
	ret i64 %1
}

define fastcc i32 @System.InterLockedExchangeAdd(i32* %dest, i32 %value)
{
	%1 = atomicrmw add i32* %dest, i32 %value seq_cst
	ret i32 %1
}

define fastcc i64 @System.InterLockedExchangeAdd64(i64* %dest, i64 %value)
{
	%1 = atomicrmw add i64* %dest, i64 %value seq_cst
	ret i64 %1
}

define fastcc i32 @System.InterLockedExchange(i32* %dest, i32 %value)
{
	%1 = atomicrmw xchg i32* %dest, i32 %value seq_cst
	ret i32 %1
}

define fastcc i64 @System.InterLockedExchange64(i64* %dest, i64 %value)
{
	%1 = atomicrmw xchg i64* %dest, i64 %value seq_cst
	ret i64 %1
}
