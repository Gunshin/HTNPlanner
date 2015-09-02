package htnPlanner;

/**
 * ...
 * @author 
 */
class ValueIntRange extends Value
{

	var lowerBound:Int = 0;
	var upperBound:Int = 0;
	
	public function new(name_:String) 
	{
		super(name_);
	}
	
	override public function GetPossibleValues():Array<String>
	{
		var vals:Array<String> = new Array<String>();
		
		for (i in lowerBound...upperBound + 1)
		{
			vals.push(Std.string(i));
		}
		
		return vals;
	}
	
	
	
	public function SetLowerBound(lower_:Int)
	{
		lowerBound = lower_;
	}
	
	public function GetLowerBound():Int
	{
		return lowerBound;
	}
	
	public function SetUpperBound(upper_:Int)
	{
		upperBound = upper_;
	}
	
	public function GetUpperBound():Int
	{
		return upperBound;
	}
	
	
	
}