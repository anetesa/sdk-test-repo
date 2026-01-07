export type TwoFactorMethod = {
  authenticator: object;
  id: string;
  lastUsed: boolean;
  method: string;
  email?: string;
  mobilePhone?: string;
};

export type LoginResponse = {
  methods?: TwoFactorMethod[];
  twoFactorId?: string;
  user?: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  };
  token?: string;
  refreshToken?: string;
  changePasswordId?: string;
};

export type LoginRequest = {
  loginId: string;
  password: string;
  applicationId: string;
};

export type TwoFactorRequest = {
  twoFactorId: string;
  code: string;
  trustComputer?: boolean;
  userEmail?: string;
};

export type TwoFactorResponse = {
  refreshToken: string;
  refreshTokenId: string;
  twoFactorTrustId?: string;
  token: string;
  tokenExpirationInstant: number;
  trustToken: string;
  changePasswordId?: string;
  user: {
    active: boolean;
    connectorId: string;
    data: {
      InitialAccount: string;
    };
    email: string;
    firstName: string;
    id: string;
    insertInstant: number;
    lastLoginInstant: number;
    lastName: string;
    lastUpdateInstant: number;
    memberships: any[];
    passwordChangeRequired: boolean;
    passwordLastUpdateInstant: number;
    preferredLanguages: string[];
    registrations: any[];
    tenantId: string;
    twoFactor: {
      methods: any[];
      recoveryCodes: string[];
    };
    usernameStatus: 'ACTIVE';
    verified: boolean;
  };
};

export interface MeProfileResponse {
  defaultSupport?: SupportInfoDTO;
  email?: string | null;
  id?: string;
  profiles?: ProfileResponseDTO[] | null;
  selectedProfileRoleName?: string | null;
  userType?: string | null;
  userTypeId?: number;
}

export interface ProfileResponseDTO {
  accountCreatedOn?: string | null;
  accountName?: string | null;
  address?: string | null;
  affiliateBusinessModelTypeId?: number | null;
  affiliateId?: string | null;
  firstName?: string | null;
  id?: string;
  isMainContact?: boolean;
  lastName?: string | null;
  mccCode?: string | null;
  mccCodeDescription?: string | null;
  merchantId?: string | null;
  permissions?: string[] | null;
  roleName?: string | null;
  status?: string | null;
  statusId?: number | null;
  support?: SupportInfoDTO;
}
export interface SupportInfoDTO {
  email?: string | null;
  name?: string | null;
  phoneNumber?: string | null;
  supportProviderTypeId?: number;
  website?: string | null;
}

export type DeviceRegistrationRequest = {
  merchantId: string;
  deviceName: string;
  deviceId: string;
};

export type DeviceRegistrationResponse = {
  deviceId: string;
};
