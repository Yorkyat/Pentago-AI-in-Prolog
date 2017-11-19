/*
	1	2	3	4	5	6
	7	8	9	10	11	12
	13	14	15	16	17	18
	19	20	21	22	23	24
	25	26	27	28	29	30
	31	32	33	34	35	36
*/
emptyBoard([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36]).

% 32 possible winning cases
winList([[1,7,13,19,25],[5,11,17,23,29],[8,9,10,11,12],[13,14,15,16,17],
	[1,2,3,4,5],[5,10,15,20,25],[8,15,22,29,36],[14,15,16,17,18],
	[1,8,15,22,29],[6,12,18,24,30],[9,15,21,27,33],[19,20,21,22,23],[2,8,14,20,26],
	[6,11,16,21,26],[10,16,22,28,34],[20,21,22,23,24],[2,3,4,5,6],[7,13,19,25,31],
	[11,17,23,29,35],[25,26,27,28,29],[2,9,16,23,30],[7,8,9,10,11],[11,16,21,26,31],
	[26,27,28,29,30],[3,9,15,21,27],[7,14,21,28,35],[12,18,24,30,36],[31,32,33,34,35],
	[4,10,16,22,28],[8,14,20,26,32],[12,17,22,27,32],[32,33,34,35,36]]).

/*					Threatening					*/
% counting no. of threats
counting(_, _, [], 0) :- !.
counting(OpPosList, CurPosList, [H|T], N) :- 
	counting(OpPosList, CurPosList, T, NN),
	(intersection(OpPosList, H, InterList), length(InterList, 4), 
	subtract(H, InterList, [Rest]), not(member(Rest, CurPosList)) -> N is NN + 1; N is NN).

threatening(board(BlackList, RedList), black, ThreatsCount) :- winList(W), counting(RedList, BlackList, W, ThreatsCount).
threatening(board(BlackList, RedList), red, ThreatsCount) :- winList(W), counting(BlackList, RedList, W, ThreatsCount).

/*
	Working Flow
	first layer: check win, if not then rotate, if not then go to second layer
	second layer: check win, if not then rotate, if not then count threatcounts
	find max of the threatcounts got in second layer -> the threatcount for the first layer
	find min of the threatcounts of the first layer
*/
/*
	BestMove = move(Pos, Direction, Quadrant)

	1. checkwin, appended list
	2. checkwin after rotation, appended list after rotation
	3. append Pos to BlackList/RedList, find new MoveableList, checkwin, appended list
	4. checkwin after rotation, appended list after rotation
	5. calculate threatcount
*/

findMoveableList(BlackList, RedList, MoveableList) :- emptyBoard(EmptyBoard), subtract(EmptyBoard, BlackList, TempList), subtract(TempList, RedList, MoveableList), !.

genRotationList(Pos, List) :- List = [move(Pos, clockwise, top-left), move(Pos, anti-clockwise, top-left), 
									move(Pos, clockwise, top-right), move(Pos, anti-clockwise, top-right),
									move(Pos, clockwise, bottom-left), move(Pos, anti-clockwise, bottom-left),
									move(Pos, clockwise, bottom-right), move(Pos, anti-clockwise, bottom-right)], !.

% generate moveable list with 8 rotations
genFullMoveableList([], InitialList, _, FullMoveableList) :- FullMoveableList = InitialList, !.
genFullMoveableList([H|T], InitialList, FinalList, FullMoveableList) :- genRotationList(H, RotPosList), 
													append(InitialList, RotPosList, FinalList), 
													genFullMoveableList(T, FinalList, _, FullMoveableList).

% List: List to be checked, [H|T]: winList
checkwin(_, []) :- fail.
checkwin(List, [H|T]) :- 
	(intersection(List, H, InterList), length(InterList, 5)), !;
	checkwin(List, T).

/*
	clockwise
	1	2	3		13	7	1		+2	+7	+12
	7	8	9	->	14	8	2	=	-5	+0	+5
	13	14	15		15	9	3		-12	-7	-2
*/
isQuad(N, top-left) :- member(N, [1, 2, 3, 7, 8, 9, 13, 14, 15]).
isQuad(N, top-right) :- member(N, [4, 5, 6, 10, 11, 12, 16, 17, 18]).
isQuad(N, bottom-left) :- member(N, [19, 20, 21, 25, 26, 27, 31, 32, 33]).
isQuad(N, bottom-right) :- member(N, [22, 23, 24, 28, 29, 30, 34, 35, 36]).
rotateClockwise(Q, N, R) :- member(N, [1, 4, 19, 22]), (isQuad(N, Q), R is N + 2; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [2, 5, 20, 23]), (isQuad(N, Q), R is N + 7; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [3, 6, 21, 24]), (isQuad(N, Q), R is N + 12; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [7, 10, 25, 28]), (isQuad(N, Q), R is N - 5; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [8, 11, 26, 29]), (isQuad(N, Q), R is N; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [9, 12, 27, 30]), (isQuad(N, Q), R is N + 5; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [13, 16, 31, 34]), (isQuad(N, Q), R is N - 12; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [14, 17, 32, 35]), (isQuad(N, Q), R is N - 7; R is N), !.
rotateClockwise(Q, N, R) :- member(N, [15, 18, 33, 36]), (isQuad(N, Q), R is N - 2; R is N), !.

rotate(List, move(_, clockwise, Quadrant), ResList) :- maplist(rotateClockwise(Quadrant), List, ResList), !.
rotate(List, move(_, anti-clockwise, Quadrant), ResList) :- rotate(List, move(_, clockwise, Quadrant), TempList), rotate(TempList, move(_, clockwise, Quadrant), TempTempList), rotate(TempTempList, move(_, clockwise, Quadrant), ResList), !.

genNextBoard(CurPosList, OpPosList, move(Pos, Dir, Quad), NewCurMoveList, NewOpMoveList) :- rotate(CurPosList, move(Pos, Dir, Quad), NewCurMoveListTemp),
																							sort(NewCurMoveListTemp, NewCurMoveList),
																							rotate(OpPosList, move(Pos, Dir, Quad), NewOpMoveListTemp),
																							sort(NewOpMoveListTemp, NewOpMoveList).


findVal(_, _, _, [], Initial, _, MaxValList) :- MaxValList = Initial, !.
findVal(Color, FirstLayerCurPosList, FirstLayerOpPosList, [move(Pos, Dir, Quad)|T], Initial, Final, MaxValList) :- (
																				(
																					winList(W), 
																					append(FirstLayerCurPosList, [Pos], SecondLayerList),
																					checkwin(SecondLayerList, W),
																					append(Initial, [[1000, move(Pos, Dir, Quad)]], Final)														
																				);
																				(
																					(
																						winList(W), 
																						append(FirstLayerCurPosList, [Pos], SecondLayerList),
																						rotate(SecondLayerList, move(Pos, Dir, Quad), SecondLayerRotList),
																						checkwin(SecondLayerRotList, W),
																						append(Initial, [[1000, move(Pos, Dir, Quad)]], Final)
																					);
																					(
																						(Color == black)->(
																											append(FirstLayerCurPosList, [Pos], SecondLayerList),
																											genNextBoard(SecondLayerList, FirstLayerOpPosList, move(Pos, Dir, Quad), ThirdLayerCurPosList, ThirdLayerOpPosList),
																											threatening(board(ThirdLayerOpPosList, ThirdLayerCurPosList), black, ThreatsCount),
																											append(Initial, [[ThreatsCount, move(Pos, Dir, Quad)]], Final)
																										);
																										(
																											append(FirstLayerCurPosList, [Pos], SecondLayerList),
																											genNextBoard(SecondLayerList, FirstLayerOpPosList, move(Pos, Dir, Quad), ThirdLayerCurPosList, ThirdLayerOpPosList),
																											threatening(board(ThirdLayerCurPosList, ThirdLayerOpPosList), red, ThreatsCount),
																											append(Initial, [[ThreatsCount, move(Pos, Dir, Quad)]], Final)
																										)

																					)										
																				)
																				), findVal(Color, FirstLayerCurPosList, FirstLayerOpPosList, T, Final, _, MaxValList).

retrieveVal([Val, _], R) :- R = Val, !.

% not win in first put, go to the first layer
goToFirstLayer(_, _, _, [], Initial, _, MinValList) :- MinValList = Initial, !.
goToFirstLayer(Color, CurPosList, OpPosList, [move(Pos, Dir, Quad)|T], Initial, Final, MinValList) :- append(CurPosList, [Pos], FirstLayerList),
																										genNextBoard(FirstLayerList, OpPosList, move(Pos, Dir, Quad), FirstLayerCurPosList, FirstLayerOpPosList),
																										findMoveableList(FirstLayerOpPosList, FirstLayerCurPosList, FirstLayerMoveableList),
																										genFullMoveableList(FirstLayerMoveableList, [], _, FirstLayerFullMoveableList),
																										findVal(Color, FirstLayerOpPosList, FirstLayerCurPosList, FirstLayerFullMoveableList, [], _, MaxValList),
																										msort(MaxValList, SortMaxValList),
																										last(SortMaxValList, MaxVal),
																										retrieveVal(MaxVal, Val),
																										append(Initial, [[Val, move(Pos, Dir, Quad)]], Final),
																										goToFirstLayer(Color, CurPosList, OpPosList, T, Final, _, MinValList).
% win in first put
findBestMove(_, _, [], _, _, _) :- fail.
findBestMove(CurPosList, OpPosList, [move(Pos, Dir, Quad)|T], BestMove, NewCurMoveList, NewOpMoveList) :- (
																											winList(W), 
																											append(CurPosList, [Pos], FirstLayerList),
																											checkwin(FirstLayerList, W),
																											BestMove = move(Pos, Dir, Quad),
																											%genNextBoard(FirstLayerList, OpPosList, BestMove, NewCurMoveList, NewOpMoveList),
																											NewCurMoveList = FirstLayerList,
																											NewOpMoveList = OpPosList,
																											!
																										);
																										(
																											winList(W), 
																											append(CurPosList, [Pos], FirstLayerList),
																											rotate(FirstLayerList, move(Pos, Dir, Quad), FirstLayerRotList),
																											checkwin(FirstLayerRotList, W),
																											BestMove = move(Pos, Dir, Quad),
																											genNextBoard(FirstLayerList, OpPosList, BestMove, NewCurMoveList, NewOpMoveList),
																											!
																										);
																										(
																											findBestMove(CurPosList, OpPosList, T, BestMove, NewCurMoveList, NewOpMoveList)
																										)
																										.
																				
retrieveBestMove([_, move(Pos, Dir, Quad)], BestMove) :- BestMove = move(Pos, Dir, Quad), !.

getPos(move(Pos, _, _), R) :- R = Pos, !.

pentago_ai(board(BlackList, RedList), black, BestMove, board(NewBlackList, NewRedList)) :- (findMoveableList(BlackList, RedList, MoveableList), 
																							genFullMoveableList(MoveableList, [], _, FullMoveableList), 
																							findBestMove(BlackList, RedList, FullMoveableList, BestMove, NewBlackList, NewRedList));
																							(
																								findMoveableList(RedList, BlackList, MoveableList), 
																								genFullMoveableList(MoveableList, [], _, FullMoveableList),
																								goToFirstLayer(black, BlackList, RedList, FullMoveableList, [], _, MinValList),
																								msort(MinValList, SortMinValList),
																								reverse(SortMinValList, RevSortMinValList),
																								last(RevSortMinValList, MinVal),
																								retrieveBestMove(MinVal, BestMove),
																								getPos(BestMove, Pos),
																								append(BlackList, [Pos], TempBlackList),
																								genNextBoard(TempBlackList, RedList, BestMove, NewBlackList, NewRedList)
																							).
																							%(BestMove = move(1, clockwise, top-left),NewBlackList = [],NewRedList = []).

pentago_ai(board(BlackList, RedList), red, BestMove, board(NewBlackList, NewRedList)) :- (findMoveableList(RedList, BlackList, MoveableList), 
																							genFullMoveableList(MoveableList, [], _, FullMoveableList),
																							findBestMove(RedList, BlackList, FullMoveableList, BestMove, NewRedList, NewBlackList));
																							(
																								findMoveableList(RedList, BlackList, MoveableList), 
																								genFullMoveableList(MoveableList, [], _, FullMoveableList),
																								goToFirstLayer(red, RedList, BlackList, FullMoveableList, [], _, MinValList),
																								msort(MinValList, SortMinValList),
																								reverse(SortMinValList, RevSortMinValList),
																								last(RevSortMinValList, MinVal),
																								retrieveBestMove(MinVal, BestMove),
																								getPos(BestMove, Pos),
																								append(RedList, [Pos], TempRedList),
																								genNextBoard(TempRedList, BlackList, BestMove, NewRedList, NewBlackList)
																							).
																							%(BestMove = move(1, clockwise, top-left),NewBlackList = [],NewRedList = []).

/*
pentago_ai(board(BlackList, RedList),black,move(3,clockwise,top-right),NextBoard).
pentago_ai(board(BlackList, RedList),red,move(3,clockwise,top-right),NextBoard).
*/

/*
test case black first put win
pentago_ai(board([1, 3, 10, 15, 20, 25, 30, 36], [2, 4, 19, 21, 26, 32, 34, 35]), black, BestMove, NextBoard).
pentago_ai(board([8, 20, 26, 32], [5, 16, 24, 29]), black, BestMove, NextBoard).

test case red first put win
pentago_ai(board([2, 4, 19, 21, 26, 32, 34, 35], [1, 3, 10, 15, 20, 25, 30, 36]), red, BestMove, NextBoard).

test case black first put rotate win
pentago_ai(board([9, 20, 26, 32], [5, 16, 24, 29]), black, BestMove, NextBoard).

test case red first put rotate win
pentago_ai(board([5, 16, 24, 29], [9, 20, 26, 32]), red, BestMove, NextBoard).

*/