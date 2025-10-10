// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ---------- Base / Abstract ---------- */
abstract contract Employee {
    uint public idNumber;
    uint public managerId;

    constructor(uint _idNumber, uint _managerId) {
        idNumber = _idNumber;
        managerId = _managerId;
    }

    function getAnnualCost() public view virtual returns (uint);
}

/* ---------- Salaried Employee ---------- */
contract Salaried is Employee {
    uint public annualSalary;

    constructor(uint _idNumber, uint _managerId, uint _annualSalary)
        Employee(_idNumber, _managerId)
    {
        annualSalary = _annualSalary;
    }

    function getAnnualCost() public view override returns (uint) {
        return annualSalary;
    }
}

/* ---------- Hourly Employee ---------- */
contract Hourly is Employee {
    uint public hourlyRate;

    constructor(uint _idNumber, uint _managerId, uint _hourlyRate)
        Employee(_idNumber, _managerId)
    {
        hourlyRate = _hourlyRate;
    }

    function getAnnualCost() public view override returns (uint) {
        return hourlyRate * 2080; // 2080 hours/year
    }
}

/* ---------- Manager Base ---------- */
contract Manager {
    uint[] private _employeeIds;

    /* ---------- Events ---------- */
    event ReportAdded(uint employeeId);
    event ReportsReset();

    /* ---------- Methods ---------- */
    function addReport(uint _employeeId) public {
        _employeeIds.push(_employeeId);
        emit ReportAdded(_employeeId);
    }

    function resetReports() public {
        delete _employeeIds;
        emit ReportsReset();
    }

    function getReports() public view returns (uint[] memory) {
        return _employeeIds;
    }
}

/* ---------- Salesperson (inherits Hourly) ---------- */
contract Salesperson is Hourly {
    constructor(uint _idNumber, uint _managerId, uint _hourlyRate)
        Hourly(_idNumber, _managerId, _hourlyRate)
    {}
}

/* ---------- Engineering Manager (inherits Salaried & Manager) ---------- */
contract EngineeringManager is Salaried, Manager {
    constructor(uint _idNumber, uint _managerId, uint _annualSalary)
        Salaried(_idNumber, _managerId, _annualSalary)
        Manager() // ← 明示的に呼ぶ
    {}
}

/* ---------- Submission Wrapper ---------- */
contract InheritanceSubmission {
    address public salesPerson;
    address public engineeringManager;

    constructor(address _salesPerson, address _engineeringManager) {
        salesPerson = _salesPerson;
        engineeringManager = _engineeringManager;
    }
}
