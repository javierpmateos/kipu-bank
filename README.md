# KipuBank 🏦

Un contrato inteligente seguro que implementa un sistema de bóvedas personales donde los usuarios pueden depositar y retirar ETH con límites configurables.

## 📋 Descripción

KipuBank es un contrato inteligente desarrollado en Solidity (con fines educativos) que permite a los usuarios:
- Depositar ETH en sus bóvedas personales
- Retirar fondos con límites por transacción
- Operar dentro de un límite global de depósitos del banco
- Realizar transacciones de forma segura siguiendo las mejores prácticas de Web3

### Características Principales

- **Bóvedas Personales**: Cada usuario tiene su propia bóveda para almacenar ETH
- **Límite de Retiro**: Retiros limitados por transacción para mayor seguridad
- **Límite Global**: El banco tiene una capacidad máxima total de depósitos
- **Eventos Detallados**: Seguimiento completo de todas las operaciones
- **Seguridad Avanzada**: Implementa patrones de seguridad estándar de la industria

## 🏗️ Arquitectura del Contrato

### Variables de Estado
- `i_withdrawalLimit`: Límite máximo por retiro (inmutable)
- `i_bankCap`: Capacidad máxima del banco (inmutable)
- `s_totalDeposits`: Total depositado en el banco
- `s_depositCount`: Número total de depósitos
- `s_withdrawalCount`: Número total de retiros
- `s_vaults`: Mapping de balances por usuario

### Funciones Principales

#### Funciones Externas
- `deposit()`: Depositar ETH en la bóveda personal (payable)
- `withdraw(uint256 _amount)`: Retirar ETH de la bóveda personal
- `getVaultBalance(address _user)`: Consultar balance de una bóveda (view)
- `getBankInfo()`: Obtener información general del banco (view)

#### Funciones Privadas
- `_safeTransfer()`: Transferencia segura de ETH

### Eventos
- `Deposit`: Emitido en cada depósito exitoso
- `Withdrawal`: Emitido en cada retiro exitoso

### Errores Personalizados
- `ZeroDepositNotAllowed`: No se permiten depósitos de 0 ETH
- `BankCapacityExceeded`: Se excedió la capacidad del banco
- `ZeroWithdrawalNotAllowed`: No se permiten retiros de 0 ETH
- `InsufficientVaultBalance`: Balance insuficiente en la bóveda
- `WithdrawalLimitExceeded`: Se excedió el límite de retiro
- `TransferFailed`: Falló la transferencia de ETH

## 🚀 Instrucciones de Despliegue

### Prerrequisitos
- Node.js v18 o superior
- Hardhat o Foundry
- Contar con ETH en testnet (Sepolia recomendada)
- MetaMask configurada

### Pasos de Despliegue

1. **Clonar el repositorio**
```bash
git clone https://github.com/javierpmateos/kipu-bank.git
cd kipu-bank
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Configurar variables de entorno**
Crear un archivo `.env`:
```
PRIVATE_KEY=tu_private_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/tu_infura_key
ETHERSCAN_API_KEY=tu_etherscan_api_key
```

4. **Desplegar en testnet**
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### Parámetros de Constructor

Al desplegar, especifica:
- `_withdrawalLimit`: Límite máximo por retiro (en wei)
- `_bankCap`: Capacidad máxima del banco (en wei)

**Ejemplo:**
```solidity
// Límite de retiro: 0.005 ETH
// Capacidad del banco: 0.02 ETH
KipuBank bank = new KipuBank(5000000000000000, 20000000000000000);
```

## 🔧 Cómo Interactuar con el Contrato

### Usando Web3/Ethers.js

```javascript
const contractABI = [...]; // ABI del contrato
const contractAddress = "0x..."; // Dirección desplegada
const contract = new ethers.Contract(contractAddress, contractABI, signer);

// Depositar 0.5 ETH
await contract.deposit({ value: ethers.utils.parseEther("0.5") });

// Retirar 0.1 ETH
await contract.withdraw(ethers.utils.parseEther("0.1"));

// Consultar balance
const balance = await contract.getVaultBalance(userAddress);
console.log(`Balance: ${ethers.utils.formatEther(balance)} ETH`);
```

### Usando Etherscan

1. Ve a la dirección del contrato en [Sepolia Etherscan](https://sepolia.etherscan.io)
2. Navega a la pestaña "Write Contract"
3. Conecta tu wallet
4. Usa las funciones disponibles:
   - `deposit`: Envía ETH junto con la transacción
   - `withdraw`: Especifica la cantidad en wei

### Usando Remix IDE

1. Abre [Remix](https://remix.ethereum.org)
2. Importa el contrato desde GitHub
3. Compila con Solidity 0.8.26+
4. Despliega o conecta a una instancia existente
5. Interactúa usando la interfaz gráfica

## 📊 Funciones de Consulta

```solidity
// Obtener balance de un usuario
uint256 balance = bank.getVaultBalance(address);

// Obtener información general
(
    uint256 totalDeposits,
    uint256 bankCap,
    uint256 withdrawalLimit,
    uint256 deposits,
    uint256 withdrawals
) = bank.getBankInfo();

// Consultar límites (variables públicas)
uint256 maxWithdrawal = bank.i_withdrawalLimit();
uint256 maxCapacity = bank.i_bankCap();
```

## 🔒 Características de Seguridad

- **Checks-Effects-Interactions**: Patrón aplicado en todas las funciones
- **Reentrancy Protection**: Uso de `.call()` seguro
- **Input Validation**: Validación exhaustiva de parámetros
- **Custom Errors**: Errores específicos para mejor debugging
- **Immutable Variables**: Límites inmutables tras despliegue
- **Safe Math**: Protección contra overflow/underflow (Solidity 0.8+)

## 📈 Casos de Uso

### Ejemplo de Flujo Típico

1. **Usuario deposita 0.01 ETH**
   - Verifica que no se exceda `i_bankCap` (0.02 ETH total)
   - Actualiza `s_vaults[usuario] += 0.01 ETH`
   - Emite evento `Deposit`

2. **Usuario intenta retirar 0.008 ETH**
   - Si `i_withdrawalLimit < 0.008 ETH` → revierte (límite es 0.005 ETH)
   - Usuario debe retirar máximo 0.005 ETH por transacción
   - Si balance suficiente → procede
   - Actualiza balance y emite evento

3. **Consulta de estado**
   - Cualquiera puede consultar balances
   - Información del banco disponible públicamente

## 📋 Información del Contrato Desplegado

- **Red**: Sepolia Testnet
- **Dirección**: `0x03fd8310c0c0ad6e132fea632d25f7d00a46e7e3`
- **Explorador**: [Ver en Etherscan](https://sepolia.etherscan.io/address/0x03fd8310c0c0ad6e132fea632d25f7d00a46e7e3)
- **Verificado**: Si

### Parámetros de Despliegue
- **Límite de Retiro**: 0.005 ETH (5000000000000000 wei)
- **Capacidad del Banco**: 0.02 ETH (20000000000000000 wei)

## 🛠️ Desarrollo

### Estructura del Proyecto
```
kipu-bank/
├── contracts/
│   └── KipuBank.sol
├── LICENSE
└── README.md
```

## 📄 Licencia

Este proyecto está licenciado bajo MIT License.

## 🔗 Links Útiles

- [Documentación de Solidity](https://docs.soliditylang.org/)
- [Remix](https://remix.ethereum.org)
- [Hardhat](https://hardhat.org/docs)
- [Sepolia Testnet](https://sepolia.etherscan.io/)

---

**⚠️ Disclaimer**: Este contrato es para fines educativos. Realiza una auditoría completa antes de usar en producción.

**📧 Contacto**: [sec**@gmail.com]

---

*Desarrollado con ❤️ para el ecosistema Web3*
