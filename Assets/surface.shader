Shader "Custom/surface"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Metallic("Metalic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _BumpMap ("Normalmap", 2D) = "bump" {} // ����Ƽ�� �������̽��κ��� �Է¹޴� �������� '_BumpMap' �̶�� ������, �ؽ��� �������̽��� �븻���� ���� ���̶�� ������. �׷��� �븻�� �ؽ��ĸ� �Է����� �����Ÿ� �ٸ� �Ϲ� �������̽��� ����� ���޽����� ���.
        _Occlusion ("Occlusion", 2D) = "white" {} // ��Ŭ���� �ؽ��ĸ� �ޱ� ���� �߰��� �������̽�
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Occlusion; // ��Ŭ���� �ؽ��İ� �� ����
        float _Metallic;
        float _Smoothness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            /*
                �븻�� �ؽ��ĸ� ����Ƽ���� Texture Type �� �븻������ �������ָ�,
                �ش� �ؽ��İ� DXTnm ���� �������� ��ȯ��.

                �� ������ ������ �븻���� R, G ���� �ִ��� �����Ͽ�
                ���� A, G ���� �־ ������ ������.

                ���� �� A, G ���� X, Y�� ����ϰ�, Z���� �ﰢ�Լ��� �����ϴµ�,
                �̷��� ����� ��� ���ִ� ����Ƽ ���̴� ��ũ��Ʈ �Լ���
                UnpackNormal() �̶�� ���� ��.

                UnpackNormal() �Լ��� ���ڷ� float4 �� 
                (��, tex2D() �Լ��� ������ �븻�� �ؽ����� �ؼ���) �� �ް�,
                ������� float3 (��, ������ ���� X, Y, Z) �� ����.

                �� ���� SurfaceOutputStandard(���Ĵٵ� ���̴�) ����ü�� 
                Normal ���� �־��ָ� �븻���� �����!
            */
            fixed3 n = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            // o.Normal = n;
            o.Normal = float3(n.x * 2, n.y * 2, n.z); // �̷� ������ float3 n ���� �̸� ���س��� ��, n.x, y �� Ư�� ���� ���ؼ� �־��ָ� �븻���� ������ ������ �� ����.

            /*
                SurfaceOutputStandard(���Ĵٵ� ���̴�) ����ü�� ��Ŭ���� ���� half, ��
                1���� float ������ ����.

                �� �׷���?
                ��Ŭ���� �� �ؽ��ĸ� ���� �˰�����
                ������� �Ǿ����ݾ�!

                ������� �Ǿ������� �翬�� 
                float �� 1���� ������ ǥ���� �����Ѱ���.

                ȯ�汤�� ���� ���ϴ� ������ 
                ȯ�� ���� �׸��ڰ��� ǥ���Ϸ��� �Ŵϱ�.

                �׷��� ���� float4 �ؼ����� �������ִ� tex2D �Լ���
                ���ϰ����� �Ҵ��ϰ� ����?

                �̷� ���, float4 �� ù ��° ��, �� r ä�� ���� ����ϰ�,
                ������ ä���� ������ �׳� ������.

                �׷��� o.Occlusion ���� 1���� ���� ���� �Ǵ� ��!
            */
            o.Occlusion = tex2D(_Occlusion, IN.uv_MainTex); // ����� ��Ŭ���� ���� �ؼ����� o.Occlusion �� �Ҵ��� ��, ������ uv ���ؽ� ��ǥ���� ������ ������ ����, ��� _MainTex ���� ����ϴ� �Ͱ� ������ uv �� ����ؾ� ���� �۵��Ѵٰ� ��!

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

/*
    Occlusion �� ���� ������ p.231 ����.

    ��Ŭ���� �ؽ��Ĵ� �ؼ����� r���� ����ϱ� ������,
    rgba ���� ��� ���� �ؽ��� ������ �������� �� �ణ ������ �� ����.

    å������ _MainTex �� ���İ��� 
    ��Ŭ���� �ؽ����� �� �ڸ��� ���� rä�� ������ �־
    �ؽ��ĸ� �����ϴ� ���·� ����� ���� �ִٰ� ��.
*/