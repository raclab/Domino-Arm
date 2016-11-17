function Path = GreedSearch(Map, goal_L, current_L, Pose)
Map_Size = size(Map);

Open = [current_L, CalcDist(current_L, goal_L), 0, 0];
Closed = [];
Path = [];

while isempty(Open) == 0
    %Sort OPEN by heurestic
    [Y, I]=sort(Open(:,3));
    Open = Open(I,:);
    
    %Remove Best Node from OPEN, add it to CLOSED.
    BestNode = Open(1, :);
    Open(1, :) = [];
    Closed = [Closed; BestNode];
    
    %If Best Node is the goal state,
    if ((BestNode(1) == goal_L(1)) && (BestNode(2) == goal_L(2)) )
        %backtrace path to Best Node (through recorded parents) and return
        %path.
        
        Closed_size = size(Closed);
        Location = Closed_size(1);
        %Path = [Closed(Location, :); Path]
        while Location > 1
            Path = [Closed(Location, :); Path];
            NewLocation = Location-1;
            for i = 1:(NewLocation)
                a = NewLocation+1-i;
                if ((Closed(NewLocation+1, 4) == Closed(a, 1)) && (Closed(NewLocation+1, 5) == Closed(a, 2)) )
                    Location = a;
                end
            end
        end
       
        break;
    end
    
    %Create Best Node's successors. 
    x = BestNode(1);
    y = BestNode(2);
    D = [x, y-1];
    DL = [x-1, y-1];
    L = [x-1, y];
    UL = [(x-1), (y+1)];
    U = [x, y+1];
    UR = [x+1, y+1];
    R = [x+1, y];
    DR = [x+1, y-1];
    SN = [D; L; U; R];

    %FIND NODE FROM SN THAT EXISTS
    ESN = [];
    for i = 1:size(SN, 1)
        Node = SN(i,:);
        % Ensure that current point is within the bounds of the map
        if ( ((0 < Node(1)) && (Node(1) < Map_Size(1)+1)) && ((0 < Node(2)) && (Node(2) < Map_Size(2)+1)) )
            
            %Ensure that point in map is not equal to 0 (obstacle)
            Failed = detectCollision(Node, Map, Pose);
            if (~Failed)
                
                %Ensure that current node is not any of the current path
                %points
                Path_Size = size(Open);
                Failed = 0;
                for i = 1:Path_Size(1)
                    P = Open(i, :);
                    a = Node(1);
                    b = Node(2);
                    if ((a == P(1)) && (b == P(2)))
                        Failed = 1;
                        break;
                    end
                end
                
                %Make sure Node is not closed
                Closed_size = size(Closed);
                if (Failed == 0)
                    if (Closed_size > 0)
                        for i = 1:Closed_size(1)
                            P = Closed(i, :);
                            a = Node(1);
                            b = Node(2);
                            if ((a == P(1)) && (b == P(2)))
                                Failed = 1;
                                break;
                            end
                        end
                    end
                end
                
                if (Failed == 0)
                    ESN = [ESN; Node, CalcDist(Node, goal_L), x, y];
                end
                
            end
        end
    end
    
    ESN_size = size(ESN);
    for i = 1:ESN_size(1)
       if (ESN(i,3) < BestNode(3))
            Open = [Open; BestNode; ESN(i,:)];
            break
        else
            Open = [Open; ESN(i,:)];
        end
    end
end



end
