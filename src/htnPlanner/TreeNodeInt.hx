package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeInt extends TreeNode
{
	//it could be null since we might have two functions evaluating against each other
	var firstValue:Null<Int> = null;
	var secondValue:Null<Int> = null;

	public function new(params_:Array<String>) 
	{
		super();
		
		if (Utilities.Compare(params_[0], "") != 0)
		{
			firstValue = Std.parseInt(params_[0]);
		}
		
		if (Utilities.Compare(params_[1], "") != 0)
		{
			secondValue = Std.parseInt(params_[1]);
		}
	}
	
	override public function Evaluate(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Bool
	{
		//since we know that this is a node that deals with integers, there should be only 2 children which evaluate to integers.
		//the first child should always be some form of function, therefor we should be using Execute.
		var functionOneID:String = children[0].Execute(parameters_, state_, domain_);
		
		var functionOneValue:Int = state_.GetFunction(functionOneID);
		
		return ComparisonEvaluate(GetFirstValue(parameters_, state_, domain_), GetSecondValue(parameters_, state_, domain_));
	}
	
	public function GetFirstValue(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Int
	{
		//the second int could either be a function or a standard number
		var functionOneValue:Int = 0;
		if (secondValue != null)
		{
			functionTwoValue = secondValue;
		}
		else
		{
			var functionTwoID:String = children[0].Execute(parameters_, state_, domain_);
			var functionTwoValue:Int = state_.GetFunction(functionTwoID);
		}
		
		return functionTwoValue;
	}
	
	public function GetSecondValue(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):Int
	{
		//the second int could either be a function or a standard number
		var functionTwoValue:Int = 0;
		if (secondValue != null)
		{
			functionTwoValue = secondValue;
		}
		else
		{
			var functionTwoID:String = children[1].Execute(parameters_, state_, domain_);
			var functionTwoValue:Int = state_.GetFunction(functionTwoID);
		}
		
		return functionTwoValue;
	}
	
	public function ComparisonEvaluate(valueA_:Int, valueB_:Int):Bool { throw "must override this function"; }	
	
	override public function Execute(parameters_:Map<String, Parameter>, state_:State, domain_:Domain):String { throw "must override this function"; }
	
}