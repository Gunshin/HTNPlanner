package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Value
{
	var name:String = null;
	var lowerBound:Int = 0;
	var upperBound:Int = 0;
	
	public function new(name_:String) 
	{
		name = name_;
	}
	
	public function GetName():String
	{
		return name;
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