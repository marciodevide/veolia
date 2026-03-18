public with sharing class CDICData_CL {
    public CDICData_CL_C domesticUltimate;
    public CDICData_CL_C globalUltimate;
    public CDICData_CL_C headQuarter;
    public CDICData_CL_C parent;
    public List<CDICData_CL_FRP> familytreeRolesPlayed;
    public Integer globalUltimateFamilyTreeMembersCount;
    public Integer hierarchyLevel;
    public String branchCount;

    public class CDICData_CL_FRP{
        public String description;
        public Integer dnbCode;
    }
}