# Polygon-Pos


## İmportlar
```solidity
import "./IERC20.sol";
```
Bu satırda, `IERC20.sol` adlı başka bir dosyanın içeri aktarılması sağlanmıştır. Bu dosya, Polygon POS ağında kullanılan ERC-20 tokenlarının işlevselliğini içeren bir kontratı temsil eder. Kodun doğru çalışması için `IERC20.sol` dosyasının projenizin dizinine yerleştirilmesi gerekmektedir.

## Sözleşme Değişkenleri
```solidity
mapping(address => uint256) public entries;
mapping(address => uint256) public stakes;
address[] public participants;
bool public isClosed;
address public winner;
uint256 public totalStaked;
IERC20 public plyToken;
```
Bu kod bloğu, çekilişle ilgili bilgileri depolamak için kullanılan değişkenleri içerir. Ayrıca, PLY tokenıyla ilgili işlemler yapabilmek için `plyToken` adında bir `IERC20` türünde değişken tanımlanır.

## Etkinlikler
```solidity
event RaffleDrawn(address winner);
event Staked(address indexed user, uint256 amount);
```
Bu satırlar, `RaffleDrawn` ve `Staked` adlı iki etkinliği tanımlar. `RaffleDrawn` etkinliği, çekilişin tamamlandığında kazanan adresi içerir. `Staked` etkinliği ise kullanıcının PLY tokenlarını stakelediğinde tetiklenir ve ilgili kullanıcının adresini ve stake miktarını içerir.

## Katılım Fonksiyonu
```solidity
function enter() public payable {
    require(!isClosed, "Raffle is closed");
    require(msg.value > 0, "Entry fee must be greater than 0");
    entries[msg.sender] += msg.value;
    participants.push(msg.sender);
}
```
Bu fonksiyon, çekilişe katılmak isteyen kullanıcıların işlem yapmasını sağlar. Kullanıcıların bir giriş ücreti ödemesi gerekmektedir. `entries` mapping'i, her bir kullanıcının yaptığı giriş miktarını depolar. `participants` dizisi ise çekilişe katılan kullanıcıların adreslerini içerir.

## Stake Fonksiyonu
```solidity
function stake(uint256 amount) public {
    require(amount > 0, "Staking amount must be greater than 0");
    require(plyToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    stakes[msg.sender] += amount;
    totalStaked += amount;
    emit Staked(msg.sender, amount);
}
```
Bu fonksiyon, kullanıcıların PLY tokenlarını stakelemesine olanak tanır. Kullanıcı, belirli bir miktarda PLY tokenını akıllı sözleşmeye gönderir ve bu miktar `stakes` mapping'inde ve `totalStaked` değişkeninde güncellenir. A

yrıca, `Staked` etkinliği tetiklenir ve kullanıcının adresi ile stake miktarı içerir.

## Unstake Fonksiyonu
```solidity
function unstake(uint256 amount) public {
    require(amount > 0, "Unstaking amount must be greater than 0");
    require(stakes[msg.sender] >= amount, "Insufficient staked amount");
    stakes[msg.sender] -= amount;
    totalStaked -= amount;
    require(plyToken.transfer(msg.sender, amount), "Transfer failed");
}
```
Bu fonksiyon, kullanıcıların stakeledikleri PLY tokenlarını geri çekmelerini sağlar. Kullanıcının çekebileceği miktar, `stakes` mapping'inde saklanan stake miktarını aşmamalıdır. Kullanıcının stake miktarı güncellenir ve ilgili miktar kullanıcının adresine geri transfer edilir.

## Stakerları Getir Fonksiyonu
```solidity
function getStakers() public view returns (address[] memory) {
    address[] memory stakers = new address[](totalStaked);
    uint256 idx = 0;
    for (uint256 i = 0; i < participants.length; i++) {
        if (stakes[participants[i]] > 0) {
            stakers[idx] = participants[i];
            idx++;
        }
    }
    return stakers;
}
```
Bu fonksiyon, tüm stakerların adreslerini bir dizi olarak döndürür. `participants` dizisinde bulunan her bir kullanıcının stake miktarı kontrol edilir ve sıfırdan büyük olan kullanıcılar staker olarak kabul edilir ve `stakers` dizisine eklenir.

## Kazananı Belirleme Fonksiyonu
```solidity
function drawWinner() public {
    require(!isClosed, "Raffle is closed");
    require(participants.length > 0, "No participants in raffle");
    uint256 totalEntries = 0;
    for (uint256 i = 0; i < participants.length; i++) {
        totalEntries += entries[participants[i]];
    }
    uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % totalEntries;
    uint256 currentIndex = 0;
    for (uint256 i = 0; i < participants.length; i++) {
        currentIndex += entries[participants[i]];
        if (currentIndex >= randomIndex) {
            winner = participants[i];
            break;
        }
    }
    isClosed = true;
    emit RaffleDrawn(winner);
}
```
Bu fonksiyon, çekilişin kazananını belirlemek için kullanılır. Fonksiyon, `participants` dizisindeki her bir kullanıcının giriş miktarını toplayarak toplam giriş sayısını hesaplar. Ardından, rastgele bir kazanan belirlemek için `totalEntries` sayısını kullanır. Son olarak, kazanan kullanıcının adresi `winner` değişkenine atanır ve `RaffleDrawn` etkinliği tetiklenir.

## Ödül Talep Etme Fonksiyonu
```solidity
function claimPrize() public {
    require(msg.sender == winner, "Only the winner can claim the prize");
    payable(winner).transfer(address(this).balance);


}
```
Bu fonksiyon, çekilişi kazanan kullanıcının ödülü talep etmesini sağlar. Yalnızca kazanan kullanıcı bu fonksiyonu çağırabilir ve akıllı sözleşmenin bakiyesi (`address(this).balance`) kazanan kullanıcının adresine transfer edilir.
