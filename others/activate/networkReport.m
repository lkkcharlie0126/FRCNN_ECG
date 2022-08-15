report = r.Layers(:, 1:7);
newActivation = report.Description;
for i = 1:size(report, 1)
    Size = report.Activations(i,1).Size;
    sizeString = [];
    for j = 1:size(Size, 2)
    sizeString = [sizeString, int2str(Size(j)), ' × '];
    end
    newActivation(i,1) = string(sizeString(1:end-2));
end

newReport = [report.Index, report.Type, report.Description, newActivation, report.TotalLearnables];