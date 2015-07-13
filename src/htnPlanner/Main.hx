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

	var taskManager:TaskManager = new TaskManager();
	var state:State = new State();
	
	public function new() 
	{
		
		var tree:Tree = new Tree();
		tree.ParsePDDL("(and (at ?truck ?loc-to) (not (at ?truck ?loc-from)) (forall (?x - obj) (when (and (in ?x ?truck))(and (not (at ?x ?loc-from))(at ?x ?loc-to)))))");
		
		//taskManager.AddBasicPredicates();
		
		//state.AddRelation(["InventoryCount", "2"]);
		//state.AddRelation(["Inventory", "Wood", "0", "1", "2"]);
		
		/*{
			var prec:PreCondition = new PreCondition(0, [["Func", "<", "InventoryCount-Int", "5", "Temp-Int"]]);
			
			var result:Bool = taskManager.Evaluate(prec, state);
			trace(result);
		}*/
		
		/*taskManager.AddOperand(new Operand("BuyLand", new PreCondition(0, []), [new Effect(["Add", "Land"]), new Effect(["Add", "Money"])]));
		taskManager.AddOperand(new Operand("GetMortgage", new PreCondition(0, []), [new Effect(["Add", "Debt"]), new Effect(["Add", "Money"])]));
		
		{
			var prec:PreCondition = new PreCondition(0, [["Add", "Money"], ["Add", "Land"]]);
			var result:Array<Operand> = taskManager.MatchPreCondition(prec);
			trace(result.length);
			for (i in result)
			{
				trace(i.GetName());
			}
		}*/
		
		/*var operands:Array<Operand> = [
			new Operand("BuyLand", ["Money"], [new Effect(true, "Land"), new Effect(false, "Money")]),
			new Operand("GetLoad", ["GoodCredit"], [new Effect(true, "Money"), new Effect(true, "Mortgage")]),
			new Operand("BuildHouse", ["Land"], [new Effect(true, "House")])
		];
		
		var state:Array<String> = [
			"GoodCredit"
		];*/
		
	}
	
	/*public function GetPlan(operands_:Array<Operand>, state_:Array<String>)
	{
		
		var applicableOperands:Array<Operand> = GetApplicableOperands(operands_, state_);
		
		while (applicableOperands.length > 0)
		{
			
			
			
		}
		
	}*/
		
	/*public function GetApplicableOperands(operands_:Array<Operand>, state_:Array<String>)
	{
		var applicable:Array<Operand> = new Array<Operand>();
		
		for (i in operands_)
		{
			if (PreConditionsMet(i, state_))
			{
				applicable.push(i);
			}
		}
		
		return applicable;
		
	}*/
	
	/*public function PreConditionsMet(operand_:Operand, state_:Array<String>)
	{
		for (i in operand_.GetPreConditions())
		{
			if (State.Contains(state_, i) == -1)
			{
				return false;
			}
		}
		
		return true;
	}*/
	
	public static function main()
	{
		new Main();
	}
}