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
	
	var predicates:Map < String, Predicate > = new Map < String, Predicate > ();
	
	public function new() 
	{
	}
	
	public function AddOperand(operand_:Operand)
	{
		operands.push(operand_);
	}
	
	public function AddPredicate(predicate_:Predicate)
	{
		predicates.set(predicate_.GetName(), predicate_);
	}
	
	public function Evaluate(preConditions_:PreCondition, state_:State):Bool
	{
		
		for (i in preConditions_.preConditions)
		{
			
			//i is an Array<Strin>
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
		
		return predicates.get(funcName).Execute(params_, state_);
		
	}
	
	/* this function is here so that we can use a precondition such as:
	 * ["Inventory", "Wood"] to match against:
	 * ["Inventory", "Wood", "0", "1", "2"]
	 * 
	 * if the precondition exists in the state, then it is successful.
	 */
	function Exists(relation_:Array<String>, state_:State)
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
	
	public function AddBasicPredicates()
	{
		AddPredicate(new Predicate("==", [], 
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
					var variableValue:String = state_.Get2(split[0], "Value")[0];
					num = Std.parseInt(variableValue);
					
				}
				numbers.push(num);
			}
			
			// now that the numbers have been converted, lets check to see if all are equal
			
			for (i in 0...numbers.length - 1)
			{
				if (numbers[i] != numbers[i + 1])
				{
					return false; // a number is not equal
				}
			}
			
			return true; // all numbers equal
			
		}));
		
		AddPredicate(new Predicate("<", [],
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
					
					if (Utilities.Compare(split[1], "Int") != 0) // make sure it is the correct type
					{
						throw "Predicate < Has parameter of incorrect type: " + split[1];
					}
					var variableValue:String = state_.Get2(split[0], "Value")[0];
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
					return false; // a number is not equal
				}
			}
			
			return true; // all numbers equal
			
		}));
		
		AddPredicate(new Predicate(">", [],
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
					var variableValue:String = state_.Get2(split[0], "Value")[0];
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
					return false; // a number is not equal
				}
			}
			
			return true; // all numbers equal
			
		}));
	}
	
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