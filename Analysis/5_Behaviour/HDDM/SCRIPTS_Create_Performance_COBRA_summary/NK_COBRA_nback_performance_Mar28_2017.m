%type = 'COBRA';
%filename = theeprime-file.txt;
%TR = 2;  
CorrAns_keep = [];

[block, RunningList, LevelList, OnsetLists, OnsetList]  = dz_InterpreteEprimefile(filename, TR, 'OnsetTime', '', 'TextDisplay1');
        exptype=type;
        tc = zeros(1,3);
        if numel(type)>30 && (strncmp(type(1:32), 'Diabetes_n-back_7rep(2013-11-28)', 32) || strncmp(type(1:32), 'Diabetes_n-back_7rep(2014-09-02)', 32))
            NofBlocks = 7;
        else
            NofBlocks = 9;
        end
        CorrResp = NaN(3,NofBlocks,10);
        CorrRespHMG = NaN(3,NofBlocks,10);
        SumCorrResp = NaN(3,NofBlocks);
        for bl=1:numel(block)
            if isfield(block(bl).MainBlockHapps, 'Procedure')
                for i=1:10
                    attseq(i) = block(bl).MainBlockHapps.(['Attribute' num2str(i)]);
                end
                type = find(strcmp(block(bl).MainBlockHapps.Procedure, {'rand1proc', 'rand2proc', 'rand3proc'}));
                switch type
                    case 1, CorrAns = attseq(2:end)==attseq(1:(end-1)); CorrAns = [NaN CorrAns(:)'];
                    case 2, CorrAns = attseq(3:end)==attseq(1:(end-2)); CorrAns = [NaN(1,2) CorrAns(:)'];
                    case 3, CorrAns = attseq(4:end)==attseq(1:(end-3)); CorrAns = [NaN(1,3) CorrAns(:)'];
                end
                CorrAns_keep = [CorrAns_keep; nansum(CorrAns)]; % NK keep track of N target present trials
                switch type
                    case 1, CorrAnsHMG = attseq(2:end)==attseq(1:(end-1)); CorrAnsHMG = [0 CorrAnsHMG(:)'];
                    case 2, CorrAnsHMG = attseq(3:end)==attseq(1:(end-2)); CorrAnsHMG = [zeros(1,2) CorrAnsHMG(:)'];
                    case 3, CorrAnsHMG = attseq(4:end)==attseq(1:(end-3)); CorrAnsHMG = [zeros(1,3) CorrAnsHMG(:)'];
                end
                tc(type)=tc(type)+1;
                temp = fields(block(bl).SubBlockHapps);
                ToUse = strncmp(temp, 'TextDisplay', 11);
                strTDfields = temp(ToUse);
                for td = 1:numel(strTDfields)
                    TextDisplay = block(bl).SubBlockHapps.(strTDfields{td});
                    RespHits_RT(type, tc(type), td) = NaN;
                    RespFA_RT(type, tc(type), td) = NaN;
                    RespCorrNo_RT(type, tc(type), td) = NaN;
                    RespIncorrNo_RT(type, tc(type), td) = NaN;
                    %% RECO
                    RespHitsHMG_RT(type, tc(type), td) = NaN;
                    RespFAHMG_RT(type, tc(type), td) = NaN;
                    RespCorrNoHMG_RT(type, tc(type), td) = NaN;
                    RespIncorrNoHMG_RT(type, tc(type), td) = NaN;
                    %%
                    if isempty(TextDisplay.RESP)
                        resp(type, tc(type), td) = NaN;
                        ReactionTime(type, tc(type), td) = NaN;
                        CorrResp(type, tc(type), td) = NaN;
                        CorrRespHMG(type, tc(type), td) = NaN;
                    else
                        if strcmp(exptype(1:5), 'COBRA') && (strcmp(experiment.subject, '119') || strcmp(experiment.subject, '132') || strcmp(experiment.subject, '136'))
                            resp(type, tc(type), td) = 3-TextDisplay.RESP; % 2-ja , 3-nej becomes 1-ja 0-nej
                        elseif  strcmp(experiment.subject, '008') && strcmp(exptype, 'Diabetes_n-back_7rep(2014-09-02)_02')
                            resp(type, tc(type), td) = 3-TextDisplay.RESP; % 2-ja , 3-nej becomes 1-ja 0-nej
                        elseif strcmp(exptype, 'n-back2') && (strcmp(experiment.subject, '26411'))
                            resp(type, tc(type), td) = TextDisplay.RESP-8; % 9-ja , 8-nej becomes 1-ja 0-nej
                        elseif strcmp(exptype, 'n-back2') && (strcmp(experiment.subject, '23611'))
                            resp(type, tc(type), td) = TextDisplay.RESP-3; % 4-ja , 3-nej becomes 1-ja 0-nej
                        elseif strcmp(exptype, 'n-back2') && (strcmp(experiment.subject, '2610'))
                            switch TextDisplay.RESP
                                case 't',
                                    resp(type, tc(type), td) = 0;
                                case 'g',
                                    resp(type, tc(type), td) = 0;
                                case 'b',
                                    resp(type, tc(type), td) = 1;
                                case 'y',
                                    if experiment.session==1
                                        resp(type, tc(type), td) = 1;
                                    else
                                        resp(type, tc(type), td) = 0;
                                    end
                                otherwise
                                    resp(type, tc(type), td) = NaN;
                            end
                        elseif strcmp(exptype(1:4), 'Diab') && (strcmp(experiment.subject, '010')) && experiment.session==4 %subject 08 S2 session2 i Finess
                            resp(type, tc(type), td) = 2-(TextDisplay.RESP-1);
                        else
                            resp(type, tc(type), td) = 2-TextDisplay.RESP; % 1-ja , 2-nej becomes 1-ja 0-nej
                        end
                        if resp(type, tc(type), td)<0 || resp(type, tc(type), td)>1
                            disp(sprintf('felaktiga v?rden, %d', resp(type, tc(type), td)));
                        end
                        ReactionTime(type, tc(type), td) = TextDisplay.RT*1E-3;
                        CorrResp(type, tc(type), td) = CorrAns(td)==resp(type,tc(type),td);
                        if CorrAns(td)==1 && resp(type,tc(type),td)==1
                            RespHits_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        if CorrAns(td)==0 && resp(type,tc(type),td)==1
                            RespFA_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        if CorrAns(td)==0 && resp(type,tc(type),td)==0
                            RespCorrNo_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        if CorrAns(td)==1 && resp(type,tc(type),td)==0
                            RespIncorrNo_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        %% f?r RECO:
                        CorrRespHMG(type, tc(type), td) = CorrAnsHMG(td)==resp(type,tc(type),td);
                        if CorrAnsHMG(td)==1 && resp(type,tc(type),td)==1
                            RespHitsHMG_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        if CorrAnsHMG(td)==0 && resp(type,tc(type),td)==1
                            RespFAHMG_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        if CorrAnsHMG(td)==0 && resp(type,tc(type),td)==0
                            RespCorrNoHMG_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        if CorrAnsHMG(td)==1 && resp(type,tc(type),td)==0
                            RespIncorrNoHMG_RT(type, tc(type), td) = ReactionTime(type, tc(type), td);
                        end
                        %%
                    end
                    OnsetTime(type, tc(type), td) = TextDisplay.RelativeOnsetTime;
                    mCorrAns(type, tc(type), td) = CorrAns(td);
                end
                SumCorrResp(type, tc(type)) = nansum(CorrResp(type,tc(type),:));
            end
        end
