package planner.pddl.tree;
import planner.pddl.ActionData;
import planner.pddl.Domain;
import planner.pddl.heuristic.HeuristicData;
import planner.pddl.State;
import planner.pddl.tree.TreeNode;

/**
 * ...
 * @author Michael Stephens
 */
class TreeNodeImply extends TreeNode
{

	public function new() 
	{
		super();
	}
	
	override public function Evaluate(data_:ActionData, state_:State, domain_:Domain):Bool
	{		
		return !children[0].Evaluate(data_, state_, domain_) || children[1].Evaluate(data_, state_, domain_);
	}
	
	override public function Execute(data_:ActionData, state_:State, domain_:Domain):String
	{		
		throw "this TreeNodeImply should not be used within action effect!";
	}
	
	override public function HeuristicEvaluate(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):Bool 
	{
		return !children[0].HeuristicEvaluate(data_, heuristic_data_, state_, domain_) || children[1].HeuristicEvaluate(data_, heuristic_data_, state_, domain_);
	}
	
	override public function HeuristicExecute(data_:ActionData, heuristic_data_:HeuristicData, state_:StateHeuristic, domain_:Domain):String 
	{
		throw "this TreeNodeImply should not be used within action effect!";
	}
	
	override public function GenerateConcrete(action_data_:ActionData, state_:State, domain_:Domain):Array<TreeNode>
	{
		// so the reason why we treat the imply as an and to return anything is because generating concrete, although not entirely conformant to the name,
		// assumes that we are calling this on a state where the imply is satisfied eg. this is only called within the heuristic functions. Since we 
		// assume we are in the heuristics, the state that is passed through will contain a whole bunch of relations stating that all possible implys,
		// are correct due to the second term. We only want to pass back implys that are both relevant (eg. term/child 1) and correct with the second.
		
		// below is the exmple i use
		
		//(:action Complete_Quest
		//:parameters (?quest - quest)
		//:precondition 
			//(and
				
				//(not (done ?quest))
				//(forall (?quest_required - quest) ;; check to see if we have all the precondition quests
					//(imply (quest_required_to_do_quest ?quest ?quest_required) (done ?quest_required))
				//)
				
			//)
			//:effect 
			//(and
				//(done ?quest)
				//(increase (total-time) 1)
			//)
		//)
		
		if (children[0].Evaluate(action_data_, state_, domain_) && children[1].Evaluate(action_data_, state_, domain_))
		{
			var concrete_imply:TreeNodeImply = new TreeNodeImply();
			
			for (child in children)
			{
				concrete_imply.AddChild(child.GenerateConcrete(action_data_, state_, domain_)[0]);// each generateConcrete should only return an array of size one for an imply
			}
			
			return [concrete_imply];
		}
		
		return [];
		
	}	
	
	override public function GetRawName():String
	{
		return "imply";
	}

}