package htnPlanner;
import htnPlanner.Operand.PreCondition;
import htnPlanner.Operand.Effect;

/**
 * ...
 * @author Michael Stephens
 */
class TaskManager
{
	
	var operands:Array<Operand> = new Array<Operand>();
	
	var basicOperands:Map < String, BasicOperand > = new Map < String, BasicOperand > ();
	
	public function new() 
	{
	}
	
	public function AddOperand(operand_:Operand)
	{
		operands.push(operand_);
	}
	
	public function AddBasicOperand(basicOperand_:BasicOperand)
	{
		basicOperands.set(basicOperand_.GetName(), basicOperand_);
	}
	
	public function Evaluate(node_:TreeNode, state_:State):String
	{
		throw "not done";
		
		/*if (value_ == null || value_.length == 0)
		{
			throw "params is null or empty";
		}
		
		var basicOperand:BasicOperand = null;
		if ((basicOperand = GetBasicOperand(value_)) != null)
		{
			//basicOperand.Execute(
		}
		
		return null;*/
		
	}
	
	/*public function Evaluate(preConditions_:PreCondition, state_:State):Bool
	{
		throw "this is not done yet";
		
		// loop through each evaluation
		for (i in preConditions_.preConditions)
		{
			
			
			
			
			
			
			
			
			
			//
			var evaluationType:String = i[0];
			
			var success:Bool = true;
			
			if (Utilities.Compare(evaluationType, "Func") == 0)
			{
				success = Func(i.slice(1), state_); // cut out the first element "Func"
			}
			else
			{
				success = Exists(i, state_); // dont want to cut anything off since it is a complete relation
			}
			
			if (!success)
			{
				return false;
			}
			
		}
		
		return true;
		
	}*/
	
	function RecursivePreconditionEvaluation(params_:Array<String>):String
	{
		throw "not done yet";
		
		if (params_ == null || params_.length == 0)
		{
			throw "params is null or empty";
		}
		
		// lets get the next piece to evaluate
		var val:String = params_[0];
		
		var basicOperand:BasicOperand = null;
		if ((basicOperand = GetBasicOperand(val)) != null)
		{
			//basicOperand.Execute(
		}
		
		return null;
		
	}
	
	function GetBasicOperand(name_:String):BasicOperand
	{
		if (basicOperands.exists(name_))
		{
			return basicOperands.get(name_);
		}
		
		return null;
	}
	
	/*
	 * Functions are called via a precondition such as:
	 * ["Func","<","InventoryCount-Int","28"]
	 * 
	 * The first element "Func" is used in the above Evaluate function to specify that
	 * we want to evaluate a statement. This element is cut off.
	 * 
	 * The second element is which function in the predicate map we are referring to.
	 * "<" would be a less than function.
	 * 
	 * The elements following these are parameters for the function being called.
	 * I have decided that the best way to allow variables from a statelist into
	 * the functions is to specify variables as follows:
	 * "ID-Type" eg. "InventoryCount-Int". This allows typed parameters in, or at 
	 * least lets me know that this parameter is definitely the correct type.
	 * 
	 * or at least that is the idea anyways.
	 */
	function Func(params_:Array<String>, state_:State):Bool
	{
		var funcName:String = params_[0];
		var params_:Array<String> = params_.slice(1);
		
		return Utilities.Compare(basicOperands.get(funcName).Execute(params_, state_), "true") == 0;
		
	}
	
	/* this function is here so that we can use a precondition such as:
	 * ["Inventory", "Wood"] to match against:
	 * ["Inventory", "Wood", "0", "1", "2"]
	 * 
	 * if the precondition exists in the state, then it is successful.
	 */
	function Exists(relation_:String, state_:State)
	{
		return state_.Exists(relation_); // much simpler function
	}
	
	/*
	 * This function takes a relation, and generates an array of operands that satisfy it
	 * 
	 * 
	 * 
	 */
	public function MatchRelation(relation_:Array<String>):Array<Operand>
	{
		
		var matchingOperands:Array<Operand> = new Array<Operand>();
		
		for (i in operands)
		{
			var effects:Array<Effect> = i.GetEffects();
			
			for (effect in effects)
			{
				if (Utilities.ContainsStringArray(effect.effect, relation_))
				{
					matchingOperands.push(i); // this operand has an effect that matches the relation, add it
				}
			}
		}
		
		return matchingOperands;
	}
	
	public function MatchPreCondition(preCondition_:PreCondition):Array<Operand>
	{
		
		var preConditions:Array<Array<String>> = preCondition_.preConditions;
		var matchingOperands:Array<Operand> = new Array<Operand>();
		
		for (relation in preConditions)
		{
			
			var relationOperands:Array<Operand> = MatchRelation(relation);
			
			matchingOperands = MergeOperandArrays(matchingOperands, relationOperands);
			
		}
		
		return matchingOperands;
		
	}
	
	/*public function AddBasicPredicates()
	{
		AddBasicOperand(new BasicOperand("==", [], 
		function(params_:Array<String>, state_:State)
		{
			if (params_ == null || params_.length == 0)
			{
				throw "Predicate == Has null params_";
			}
			
			var numbers:Array<Int> = new Array<Int>();
			
			// lets convert the parameters to numbers first
			for (i in params_)
			{
				var num:Null<Int> = Std.parseInt(i);
				if (num == null) // i is not a number
				{
					// for straight variables eg. "InventoryCount", the relation will be set such as ["InventoryCount", "Value", num]
					// however, the value in the function will be "InventoryCount-Int"
					
					var split:Array<String> = i.split("-");
					
					if (Utilities.Compare(split[1], "Int") != 0) // make sure it is the correct type
					{
						throw "Predicate == Has parameter of incorrect type: " + split[1];
					}
					
					// this looks a little confusing
					// the idea is that GetMatching returns any relations that match meaning we could have multiple,
					// however when we are evaluating with these primitive operands, we are only doing it on variables,
					// meaning that the relation we are looking for _should_ only return a single array which itself has
					// only 2 elements, with the second elemtn being the value
					var variableValue:String = state_.GetMatching([split[0]])[0][1];
					num = Std.parseInt(variableValue);
					
				}
				numbers.push(num);
			}
			
			// now that the numbers have been converted, lets check to see if all are equal
			
			for (i in 0...numbers.length - 1)
			{
				if (numbers[i] != numbers[i + 1])
				{
					return "false"; // a number is not equal
				}
			}
			
			return "true"; // all numbers equal
			
		}));
		
		AddBasicOperand(new BasicOperand("<", [],
		function(params_:Array<String>, state_:State)
		{
			if (params_ == null || params_.length == 0)
			{
				throw "Predicate < Has null params_";
			}
			
			var numbers:Array<Int> = new Array<Int>();
			
			// lets convert the parameters to numbers first
			for (i in params_)
			{
				var num:Null<Int> = Std.parseInt(i);
				if (num == null) // i is not a number
				{
					// for straight variables eg. "InventoryCount", the relation will be set such as ["InventoryCount", "Value", num]
					// however, the value in the function will be "InventoryCount-Int"
					
					var split:Array<String> = i.split("-");
					
					trace("split: " + split);
					
					if (Utilities.Compare(split[1], "Int") != 0) // make sure it is the correct type
					{
						throw "Predicate < Has parameter of incorrect type: " + split[1];
					}
					
					// this looks a little confusing
					// the idea is that GetMatching returns any relations that match meaning we could have multiple,
					// however when we are evaluating with these primitive operands, we are only doing it on variables,
					// meaning that the relation we are looking for _should_ only return a single array which itself has
					// only 2 elements, with the second elemtn being the value
					var variableValue:String = state_.GetMatching([split[0]])[0][1];
					num = Std.parseInt(variableValue);
					
				}
				numbers.push(num);
			}
			
			// now that the numbers have been converted, lets check to see if all are less than the first value
			
			var left:Int = numbers[0];
			var right:Array<Int> = numbers.slice(1);
			
			for (i in 0...right.length)
			{
				if (!(left < right[i]))
				{
					return "false"; // a number is not equal
				}
			}
			
			return "true"; // all numbers equal
			
		}));
		
		AddBasicOperand(new BasicOperand(">", [],
		function(params_:Array<String>, state_:State)
		{
			if (params_ == null || params_.length == 0)
			{
				throw "Predicate > Has null params_";
			}
			
			var numbers:Array<Int> = new Array<Int>();
			
			// lets convert the parameters to numbers first
			for (i in params_)
			{
				var num:Null<Int> = Std.parseInt(i);
				if (num == null) // i is not a number
				{
					// for straight variables eg. "InventoryCount", the relation will be set such as ["InventoryCount", "Value", num]
					// however, the value in the function will be "InventoryCount-Int"
					
					var split:Array<String> = i.split("-");
					
					if (Utilities.Compare(split[1], "Int") != 0) // make sure it is the correct type
					{
						throw "Predicate > Has parameter of incorrect type: " + split[1];
					}
					
					// this looks a little confusing
					// the idea is that GetMatching returns any relations that match meaning we could have multiple,
					// however when we are evaluating with these primitive operands, we are only doing it on variables,
					// meaning that the relation we are looking for _should_ only return a single array which itself has
					// only 2 elements, with the second elemtn being the value
					var variableValue:String = state_.GetMatching([split[0]])[0][1];
					num = Std.parseInt(variableValue);
					
				}
				numbers.push(num);
			}
			
			// now that the numbers have been converted, lets check to see if all are less than the first value
			
			var left:Int = numbers[0];
			var right:Array<Int> = numbers.slice(1);
			
			for (i in 0...right.length)
			{
				if (!(left > right[i]))
				{
					return "false"; // a number is not equal
				}
			}
			
			return "true"; // all numbers equal
			
		}));
	}*/
	
	public static function MergeOperandArrays(arrayA_:Array<Operand>, arrayB_:Array<Operand>):Array<Operand>
	{
		var mergedArray:Array<Operand> = arrayA_.copy();
		
		for (bElement in arrayB_)
		{
			var contained:Bool = false;
			for (aElement in arrayA_)
			{
				if (Utilities.Compare(aElement.GetName(), bElement.GetName()) == 0)
				{
					contained = true;
					break;
				}
			}
			
			if (!contained)
			{
				mergedArray.push(bElement);
			}
			
		}
		
		return mergedArray;
	}
}