// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "./hospital.sol";

contract OMS {
    //address de la OMS (Owner del contrato)
    address public oms;

    constructor () {
        oms = msg.sender;
    }

    mapping(address => bool) public validateHospital;     //Relaciona la direccion de un Hospital validado por la OMS
    mapping(address => address) public contractHospital;  //Relaciona la direccion de un Hospital con su contrato

    address[] public addressContractHopitales;
    address[] solicitudes;

    event solicitudDeAcceso(address);
    event nuevoHospitalValidado(address);
    event nuevoContrato(address, address);

    modifier onlyOwnerOMS(address _direccion) {
        require(_direccion == oms, "No tienes permisos para ejecutar esta funcion");
        _;
    }   

    function solicitarAcceso() public {
        solicitudes.push(msg.sender);
        emit solicitudDeAcceso(msg.sender);
    }

    function getSolicitudes() public view onlyOwnerOMS(msg.sender) returns (address[] memory) {
        return solicitudes;
    }

    function altaHospitales(address _hospital) public onlyOwnerOMS(msg.sender) {
        validateHospital[_hospital] = true;
        emit nuevoHospitalValidado(_hospital);
    }

    function factoryContractHospital() public {
        require(validateHospital[msg.sender] == true, "El Hospital no es reconocido por la oms");

        address newContract = address(new Hospital(msg.sender));
        addressContractHopitales.push(newContract);
        contractHospital[msg.sender] = newContract;

        emit nuevoContrato(newContract, msg.sender);
    }
}
