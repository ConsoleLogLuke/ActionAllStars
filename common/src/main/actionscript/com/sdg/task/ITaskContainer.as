package com.sdg.task
{
	import com.sdg.task.ITask;
	
	public interface ITaskContainer extends ITask
	{
		function get numTasks():int;
	
		function addTask(task:ITask):void;
		
		function getAllTasks():Array;
		
		function removeTask(task:ITask):void;
	
		function removeAllTasks():void;
	}
}