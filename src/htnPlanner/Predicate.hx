package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class Predicate
{

	// predicates are usually defined by a keyword followed by the parameters eg. "at ?x - locatable ?l - location"
	public var firstPartOfValue:String = null;
	public var parameters:Array<Parameter> = new Array<Parameter>();
	
	public function new(predicateValue_:String) 
	{
		ParseValue(predicateValue_);
	}
	
	public function Construct(state_:State):String
	{
		
	}
	
	function ParseValue(string_:String)
	{
		
		var split:Array<String> = node_.value.split(" ");
		
		firstPartOfValue = split[0];
		
		// used to cache which values are the same, so that when a type is hit, we can set them correctly
		var currentSetOfValues:Array<String> = new Array<String>();
		
		// this indicator is used to define a type being set for values. it is flipped when a "-" is met
		var indicator:Bool = false;
		
		// set it to 1 since the first element in split is ":types"
		var index:Int = 1;
		while (index < split.length) // dont ask about god damn while loops since someone on the haxe development team had the bright idea of 
		// not allowing normal for loops. cant use foreach since they dont allow manual changing of the iterator
		{
			// check to see if the current element is empty
			if (Utilities.Compare(split[index], "") != 0)
			{
				// indicator value declaring that the next element is a type
				if (Utilities.Compare(split[index], "-") == 0)
				{
					indicator = true;
				}
				else
				{
					
					if (!indicator)
					{
						// indicator has not been set yet, so the next value is not the type
						currentSetOfValues.push(split[index]);
					}
					else
					{
						// indicator has been set, so lets set all our current values to the type
						
						for (i in currentSetOfValues)
						{
							// need to trim since the endline character might be included here
							parameters.push(new Parameter(i, StringTools.trim(split[index])));
						}
						
						currentSetOfValues = new Array<String>(); // reset the array (why is there no clear function? T_T)
						
						indicator = false;
					}
				}
			}
			
			index++;
		}
		
	}
	
}