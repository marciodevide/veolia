public with sharing class CDICData_RD {
    public CDICData_LF legalForm;
    public List<LLF> localLegalForm;

    public class LLF{
        public String code;
        public String description;
        public String scheme;
        public L language;
    }

    public class L{
        public String description;
        public Integer dnbCode;
    }
}