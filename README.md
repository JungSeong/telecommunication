# 📡 Telecommunication Algorithm
"통신 시스템 설계" 교과목, 그리고 잠시 학부 연구생 활동을 하면서 배웠던 내용입니다.
<br><br>

## OFDM.m :

**OFDM**(Orthogonal Frequency Division Multiplexing)은 부반송파에 직교성을 부여하여 병렬 데이터열을 보내는 기법을 의미합니다. 이때 직교한다는 의미는 아래의 식을 만족하는 것을 의미합니다.

OFDM subcarrier이 Φ = $e^{j 2 \pi f_i t}$로 정의될 때


$$\
\int_{0}^{T} e^{j 2 \pi f_i t} e^{2 \pi f_k t} dt = \int_{0}^{T} e^{j 2 \pi (i - k) \Delta f t} dt = 0, \quad (i \neq j)
\$$

직교성을 가진 비트열끼리는 **서로 영향을 주지 않습니다.** 따라서 송신단에서 보낸 여러 비트열이 합쳐지더라도 수신단에서 원 비트열을 정확히 복조해내게 됩니다. 또한 일반적으로 부반송파를 보낼 때 **부반송파 간 간섭**(ICI ; Inter Carrier Interference)가 발생하게 됩니다. 이를 해결하기 위해서 부반송파 간격을 충분히 떨어트리기 위해 Guard Band를 두게 되는데, 이는 **대역폭 효율**의 감소로 이어지게 됩니다. 하지만 직교성을 가진 부반송파를 보내게 된다면 Guard Band를 따로 두지 않아도 ICI가 발생하지 않기 때문에, 대역폭 효율 면에서 큰 이득을 얻게 됩니다.
<br><br>
![그림2-side](https://github.com/user-attachments/assets/62ef4a3e-be1f-4d5c-b412-423e4e9a9fa7)

아래는 OFDM 송/수신기 사진입니다. 왼쪽이 송신단, 오른쪽이 수신단입니다.

<img width="700" alt="image" src="https://github.com/user-attachments/assets/d3435cae-f49c-47d2-8427-35b1051f24ba">

MATLAB 코드를 활용하여 위의 OFDM 송/수신기를 구현하였습니다. 변조 방식을 QPSK, 16-QAM으로, subcarrier의 개수를 5개, 10개로 바꾸어 보면서 변조 방식이나 subcarrier의 수에 관계 없이 OFDM 송/수신이 잘 이루어지는지 확인하였습니다.

1. QPSK Input Data & 5 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/6fe077f0-b458-4e69-bb72-aaf2acf20e4b">

2. QPSK Input Data & 10 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/a821efa5-6e67-4d27-885b-d79997ce83ee">

3. 16-QAM Input Data & 5 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/ee96325e-b7af-49c5-a557-b0450c9d3112">

4. 16-QAM Input Data & 10 subcarriers
 <img width="700" alt="image" src="https://github.com/user-attachments/assets/a8872f5e-7166-4749-ba22-877c1dc24d34">

시뮬레이션을 통해 subcarrier의 수나 Input Data의 변조 방식에 관계 없이 송신단에서 보낸 신호가 잘 수신되는 것을 확인할 수 있었습니다.
<br><br>

## telecommunication/Multipath_OFDM.m :
위의 OFDM의 내용에 더해 더불어 Multipath, Rayleigh 통신 채널, Guard Interval & Cyclic Prefix를 추가로 고려한 통신 시스템 환경입니다.

1. Multipath Channel
현실 세계에서의 신호는 산이나 건물과 같은 장애물에 의해 반사/산란되어 여러 경로를 통해 들어오게 됩니다. 이렇게 여러 경로로 이루어진 채널을 **다중경로 채널**(Multipath Channel)이라고 합니다. 이때 송신단에서 수신단으로 바로 들어오는 신호를 **Line Of Sight**(LOS)라고 하고, 산란 및 반산되어 들어오는 신호를 **Non Line Of Sight**(NLOS)라고 합니다.
<br>

![iScreen Shoter - Canva - 241030142234](https://github.com/user-attachments/assets/a414efa0-7de1-4580-8468-779e7fe54254)

2. Rayleigh 통신 채널
Rayleigh 분포는 연속 확률 분포의 한 종류로, 현실 세계는 Rayleigh 채널을 따른다고 가정하고 있습니다.

3. Guard Interval(GI) & Cyclic Prefix (CP)
실제 무선통신 환경에서는 직접파와 delay를 두고 들어노는 반사파 끼리 **심볼 간 간섭**(ISI)이 일어나게 됩니다. 따라서 subcarrier 간 직교성이 만족되더라도 여전히 문제가 발생할 수 있는데, 이를 해결하기 위해 Guard Interval(GI)와 Cyclic Prefix(CP)라는 개념을 도입했다고 합니다.
<br>

![그림3](https://github.com/user-attachments/assets/09894b3a-034f-4f07-93b7-31610a9c334e)

Guard Interval은 하나의 심볼이 끝나면 지연되는 다른 모든 다중경로 성분들을 기다렸다가 다음 심볼을 보내는 방식을 의미합니다. 하지만 얼마나 지연될지는 사전에 알지 못하는데, 이에 일반적으로 GI는 전체 심볼의 길이의 20% 이하로 설정한다고 합니다. 그래고 Cyclic Prefix는 이 GI 구간을 비워두지 않고 그 구간의 크기 만큼 신호의 뒷 부분을 복사하여 GI 구간에 채워넣는 기법을 의미합니다.

![noname](https://github.com/user-attachments/assets/5a8cbbfb-c82e-493e-8bf3-da4f4a2d4083)

이처럼 GI 구간이 채워진다면 반사파가 완전한 정현파를 이루어 직접파와 반사파 간 ICI 문제를 해결할 수 있다고 합니다.

MATLAB 코드를 구현하여 다중 경로가 7개를 가정하고 OFDM 방식으로 비트열을 보냈을 때 BER-SNR 성능 비교 그래프를 뽑아 내었습니다.

![iScreen Shoter - MATLAB - 241030144921](https://github.com/user-attachments/assets/4245b4b8-0e05-4a6a-a584-99b01886f935)
<br><br>

## MIMO_BPSK.m, MIMO_QPSK.m :

스마트 안테나 기술 중 하나인 **MIMO**는 송/수신측에 다중 안테나를 사용하고 각 안테나에 **독립적인 신호**를 할당해 **간섭을 줄이고 전송 용량을 증대**하는 기술입니다. 여러 안테나를 통해 독립적인 신호들을 보내기 때문에 상대적으로 고속으로 데이터를 전송하는 효과를 보게 됩니다.

샤논의 정리에 의해 총 전송 용량은

$$C = B \log_{2} \left(1 + \frac{S}{N}\right) [bps] \quad , (B : 대역폭, \frac{S}{N} : 신호 대 잡음비)$$

라고 정의됩니다. 만약 송신 안테나의 개수가 M개가 된다면 총 전송 용량은

$$C = B \cdot M \cdot \log_{2} \left(1 + \frac{S}{N}\right) [bps]$$

로 선형적으로 비례해 늘어나게 됩니다. 중요한것은, 위와 같은 MIMO 기술은 **다중 경로로 들어온 신호가 서로 구분이 가능할 때** 사용 가능한 기술이므로 장애물이 많은 도심에서는 사용 가능한 반면 장애물이 거의 없는 시골에서는 사용이 불가능하다는 것입니다.

![noname](https://github.com/user-attachments/assets/2b5d4f2f-be8d-4a63-9e6f-ae3f7113a877)

한편 MIMO 방식으로 보낼 때 수신기의 검출 알고리즘은 선형 검출과 비선형 검출으로 나누어지게 됩니다. **선형 검출**은 수신된 신호에 어떤 필터 행렬 G를 곱해 원 신호를 복조해내는 알고리즘을 의미합니다.

![noname](https://github.com/user-attachments/assets/e8bd748b-4a6f-4c8f-803d-f2b1ff997009)

대표적인 선형 검출 알고리즘으로는 **Zero Forcing**(ZF), **Minimum Mean Squared Error**(MMSE)가 있습니다. 우선 ZF 알고리즘은 수신된 신호 $r = Hx + n$에 채널 *H*의 역행렬 $H^{-1}$을 곱해주어 원 신호를 복조하는 알고리즘 입니다. 하지만 역행렬은 정방 행렬일 때에만 존재하기 때문에, 이 문제를 해결하기 위해 역행렬과 유사한 **유사 역행렬**(Pseudo Inverse Matrix)를 곱하게 됩니다.

유사 역행렬 $H^{+}$ 은 다음과 같이 쓸 수 있습니다.

$$
H^{+} = H^{H} \cdot \left( H \cdot H^{H} \right)^{-1}, \quad (H^{H} : 에르메트 행렬)
$$

위와 같은 유사 역행렬을 곱하게 된다면 아래의 식에 의해 원 신호과 완벽하게 복조되게 됩니다.

$$
r \cdot H^{+} = H \cdot H^{H} \cdot \left( H \cdot H^{H} \right)^{-1} \cdot x + n \cdot H^{+} = x + n \cdot H^{+}
$$

하지만 식에서 볼 수 있듯이 잡음 항에도 $H^{+}$가 곱해지게 되어 **Noise Enhancement** 효과가 일어나게 됩니다. 이러한 잡음의 영향을 줄이기 위해 **잡음 항을 고려한 필터 행렬**을 곱해주게 되는데, 이를 MMSE 검출 알고리즘이라고 합니다.

MMSE 검출 알고리즘의 필터 행렬은 다음과 같습니다.

$$
G_{\text{MMSE}} = H^{H} \cdot \left( H \cdot H^{H} + \sigma_{Z}^{2} \cdot I \right)^{-1}
$$

한편 **비선형 검출**은 선형 검출 처럼 어떤 필터 행렬을 곱하는 것이 아닌 어떤 비 선형적인 알고리즘을 도입하여 원 신호를 복조해내는 기법을 의미합니다. 대표적인 비선형 수신 알고리즘으로는 **V-Blast**가 있습니다. 또한 이론적으로 가장 최고의 성능을 가진 검출 알고리즘으로는 ML(Maximum Likelihood) 알고리즘이 있습니다. ML 알고리즘은 수신기에서 수신된 신호 *r*을 미리 선정된 M개의 심볼과 **모두 비교**하여 가장 벡터 거리가 가까운 심볼을 고르는 방식을 의미합니다.

이를 수식으로 표현하면 다음과 같습니다.

$$
\hat{x} = \arg\min_{x} \| r - Hx \|_{F}
$$

모든 심볼과 비교하기 때문에 당연히 성능으로는 최적일 수 밖에 없으나, 한 번에 전송하는 비트의 수가 늘어남에 따라 비교해야 하는 경우의 수가 **기하급수적으로** 늘어나기 때문에 복잡한 송/수신기 에서는 사용할 수 없다는 특징을 가집니다.

MATLAB 코드를 통해 BPSK, QPSK 변조된 비트열에 대해 ZF, MMSE, ML 알고리즘으로 검출했을 때 BER-SNR 성능 그래프를 출력하였습니다.

![noname](https://github.com/user-attachments/assets/dcc5c946-48af-45b4-bce1-a3becf2c5c68)

왼쪽이 BPSK, 오른쪽이 QPSK 변조 방식에서의 BER-SNR 그래프이며, ML이 가장 성능이 좋고 그 다음으로 MMSE, ZF 순으로 성능이 좋은 것을 확인할 수 있었습니다.
