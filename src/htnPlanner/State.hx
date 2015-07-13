package htnPlanner;

/**
 * ...
 * @author Michael Stephens
 */
class State
{
	
	var relations:Array<Array<String>>;

	public function new() 
	{
		relations = new Array<Array<String>>();
	}

	public function AddRelation(relations_:Array<String>):Void
	{
		if (relations_ == null || relations_.length == 0)
		{
			return;
		}
		
		if (!Exists(relations_))
		{
			relations.push(relations_);
		}
		
	}
	
	public function Exists(relation_:Array<String>):Bool
	{
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		//check each element of the relation list
		for (i in relations)
		{
			if (Utilities.ContainsStringArray(i, relation_))
			{
				return true;
			}
		}
		
		return false; // we did not find any equivalent strings in the relation list
	}
	
	/*
	 * 
	 * Since this function can be used to get all relations that match from a substring of relations,
	 * there is a need to retunr an array.
	 * 
	 * eg.
	 * Conained relations:
	 * ["Inventory", "Logs", "10"]
	 * ["Inventory", "Axe", "1"]
	 * ["Health", "100"]
	 * 
	 * With matching relation array:
	 * ["Inventory", "Logs"]
	 * 
	 * Will return:
	 * [["Inventory", "Logs", "10"]]
	 * 
	 * Or with:
	 * ["Inventory"]
	 * 
	 * Will return:
	 * [["Inventory", "Logs", "10"], ["Inventory", "Axe", "1"]]
	 * 
	 */
	public function GetMatching(relation_:Array<String>):Array<Array<String>>
	{
		
		if (relation_ == null || relation_.length == 0)
		{
			throw "relation_ is null or empty";
		}
		
		var matchingRelations:Array<Array<String>> = new Array<Array<String>>();
		
		//check each element of the relation list
		for (i in relations)
		{
			if (Utilities.ContainsStringArray(i, relation_))
			{
				matchingRelations.push(i);
			}
		}
		
		return matchingRelations;
	}
	
}