package htnPlanner;

import htnPlanner.Operand.Effect;
import htnPlanner.Operand.PreCondition;

import htnPlanner.TaskManager;

/**
 * ...
 * @author Michael Stephens
 */
class Main 
{
	
	var fname:String = "pddlexamples/domain.pddl";
	var domain:Domain;

	var taskManager:TaskManager = new TaskManager();
	var state:State = new State();
	
	public function new() 
	{
		domain = new Domain(fname);
	}
	
	public static function main()
	{
		new Main();
	}
}